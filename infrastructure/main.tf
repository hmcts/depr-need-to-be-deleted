provider "azurerm" {}

locals {
  ase_name  = "${data.terraform_remote_state.core_apps_compute.ase_name[0]}"
  app       = "papi-api"

  api_policy = "${file("template/api-policy.xml")}"
  api_base_path = "rpa-professional-api"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.component}-${var.env}"
  location = "${var.location}"
}


module "rpa-professional-api" {
  source              = "git@github.com:hmcts/moj-module-webapp?ref=master"
  product             = "${var.product}-${var.component}"
  location            = "${var.location}"
  env                 = "${var.env}"
  ilbIp               = "${var.ilbIp}"
  resource_group_name = "${var.product}-${var.component}-${var.env}"
  subscription        = "${var.subscription}"
  capacity            = "${var.capacity}"
  common_tags         = "${var.common_tags}"

  app_settings = {
    LOGBACK_REQUIRE_ALERT_LEVEL = false
    LOGBACK_REQUIRE_ERROR_CODE  = false
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
  resource_group_name = "${var.product}-${var.component}-${var.env}"
  count               = "1"

  parameters = {
    apiManagementServiceName  = "professional-api-portal-${var.env}"
    apiName                   = "professional-api"
    apiProductName            = "papi"
    serviceUrl                = "http://${var.product}-${local.app}-${var.env}.service.core-compute-${var.env}.internal"
    apiBasePath               = "${local.api_base_path}"
    policy                    = "${local.api_policy}"
  }
}