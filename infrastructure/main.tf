provider "azurerm" {}

# Make sure the resource group exists
resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.component}-${var.env}"
  location = "${var.location_app}"
}

locals {
  ase_name               = "${data.terraform_remote_state.core_apps_compute.ase_name[0]}"
  
  app = "papi-api"
  
  allowed_certificate_thumbprints = [
    "${var.api_gateway_test_certificate_thumbprint}"
  ]

  thumbprints_in_quotes = "${formatlist("&quot;%s&quot;", local.allowed_certificate_thumbprints)}"
  thumbprints_in_quotes_str = "${join(",", local.thumbprints_in_quotes)}"
  api_policy = "${replace(file("template/api-policy.xml"), "ALLOWED_CERTIFICATE_THUMBPRINTS", local.thumbprints_in_quotes_str)}"
  api_base_path = "rpa-professional-api"
}

module "rpa-professional-api" {
  source              = "git@github.com:hmcts/moj-module-webapp?ref=master"
  product             = "${var.product}-${var.component}"
  location            = "${var.location_app}"
  env                 = "${var.env}"
  ilbIp               = "${var.ilbIp}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  subscription        = "${var.subscription}"
  capacity            = "${var.capacity}"
  common_tags         = "${var.common_tags}"

  app_settings = {
    LOGBACK_REQUIRE_ALERT_LEVEL = false
    LOGBACK_REQUIRE_ERROR_CODE  = false
  }
}

# region API
# region API manager

locals {
  name = "papi-gateway-${var.env}"
  platform_api_papi_sku = "${var.env == "prod" ? "Premium" : "Developer"}"
  
}

data "template_file" "papi_gateway_template" {
  template = "${file("${path.module}/templates/professional-api-management.json")}"
}

resource "azurerm_subnet" "api-papi-subnet" {
  name                 = "core-infra-subnet-papi-${var.env}"
  resource_group_name  = "${var.vnet_rg_name}"
  virtual_network_name = "${var.vnet_name}"
  address_prefix       = "${cidrsubnet("${var.source_range}", 4, var.source_range_index)}"

  lifecycle {
    ignore_changes = "address_prefix"
  }
}

resource "azurerm_template_deployment" "api-managment" {
  template_body       = "${data.template_file.papi_gateway_template.rendered}"
  name                = "${local.name}"
  resource_group_name = "${var.vnet_rg_name}"
  deployment_mode     = "Incremental"

  parameters = {
    location                           = "${var.location}"
    publisher_email                    = "${var.publisher_email}"
    publisher_name                     = "${var.publisher_name}"
    notification_sender_email          = "${var.notification_sender_email}"
    env                                = "${var.env}"
    platform_papi_name             = "${local.name}"
    platform_papi_subnetResourceId = "${azurerm_subnet.api-papi-subnet.id}"
    platform_papi_sku              = "${local.platform_api_papi_sku}"
  }
}


# region API template 

data "template_file" "api_template" {
  template = "${file("${path.module}/template/api-template.json")}"
}

resource "azurerm_template_deployment" "api" {
  template_body       = "${data.template_file.api_template.rendered}"
  name                = "${var.product}-api-${var.env}"
  deployment_mode     = "Incremental"
  resource_group_name = "core-infra-${var.env}"
  count               = "1"

  parameters = {
    apiManagementServiceName  = "professional-api-${var.env}"
    apiName                   = "professional-api"
    apiProductName            = "papi"
    serviceUrl                = "http://${var.product}-${local.app}-${var.env}.service.core-compute-${var.env}.internal"
    apiBasePath               = "${local.api_base_path}"
    policy                    = "${local.api_policy}"
  }
}