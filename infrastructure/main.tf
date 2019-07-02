provider "azurerm" {}

locals {
  ase_name  = "${data.terraform_remote_state.core_apps_compute.ase_name[0]}"
  app       = "professional-api"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.component}-${var.env}"
  location = "${var.location}"
}

module "rpa-professional-api" {
  source              = "git@github.com:hmcts/cnp-module-webapp?ref=master"
  product             = "${var.product}-${var.component}"
  location            = "${var.location}"
  env                 = "${var.env}"
  ilbIp               = "${var.ilbIp}"
  subscription        = "${var.subscription}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  capacity            = "${var.capacity}"
  common_tags         = "${var.common_tags}"
  asp_rg              = "rpa-${var.env}"
  asp_name            = "rpa-${var.env}"
  
  app_settings = {
    LOGBACK_REQUIRE_ALERT_LEVEL = false
    LOGBACK_REQUIRE_ERROR_CODE  = false
  }
}


# region API template 

data "template_file" "api_template" {
  template = "${file("${path.module}/template/api-template.json")}"
}

data "template_file" "test_api_def" {
  template = "${file("${path.module}/template/test-api-docs.json")}"
  vars {
    testServiceUrl = "rpa-professional-api-${var.env}.service.core-compute-${var.env}.internal"
  }
}

data "template_file" "claim_store_api_def" {
  template = "${file("${path.module}/template/claim-store-api-docs.json")}"
  vars {
    claimServiceUrl = "cmc-claim-store-${var.env}.service.core-compute-${var.env}.internal"
  }
}

data "template_file" "claim_api_def" {
  template = "${file("${path.module}/template/claim-api-docs.json")}"
  vars {
    claimServiceUrl = "cmc-claim-submit-api-${var.env}.service.core-compute-${var.env}.internal"
  }
}

resource "azurerm_template_deployment" "api" {
  template_body       = "${data.template_file.api_template.rendered}"
  name                = "${var.product}-${var.component}-${var.env}"
  deployment_mode     = "Incremental"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  count               = "1"

  parameters = {
    apiManagementServiceName  = "rpa-professional-api-portal-${var.env}"
    claimStoreDefinitionBody  = "${data.template_file.claim_store_api_def.rendered}"
    claimDefinitionBody       = "${data.template_file.claim_api_def.rendered}"
    testDefinitionBody        = "${data.template_file.test_api_def.rendered}"
    policy                    = "${file("template/api-policy.xml")}"
  }
}