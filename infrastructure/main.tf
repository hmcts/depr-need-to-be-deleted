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
  resource_group_name = "${azurerm_resource_group.rg.name}"
  subscription        = "${var.subscription}"
  capacity            = "${var.capacity}"
  common_tags         = "${var.common_tags}"
  asp_rg              = "rpa-${var.env}"
  asp_name            = "rpa-${var.env}"
  
  app_settings = {
    LOGBACK_REQUIRE_ALERT_LEVEL = false
    LOGBACK_REQUIRE_ERROR_CODE  = false
  }
}

module "local_key_vault" {
  source 					= "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                      = "${var.product}-papi-${var.env}"
  product 					= "${var.product}-${var.component}"
  env 						= "${var.env}"
  tenant_id 				= "${var.tenant_id}"
  object_id 				= "${var.jenkins_AAD_objectId}"  
  resource_group_name 		= "${azurerm_resource_group.rg.name}"
  product_group_object_id 	= "5d9cd025-a293-4b97-a0e5-6f43efce02c0"
}

# region API template 

data "template_file" "api_template" {
  template = "${file("${path.module}/template/api-template.json")}"
}

data "template_file" "claim_api_def" {
  template = "${file("${path.module}/template/claim-api-docs.json")}"
}

resource "azurerm_template_deployment" "api" {
  template_body       = "${data.template_file.api_template.rendered}"
  name                = "${var.product}-api-${var.env}"
  deployment_mode     = "Incremental"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  count               = "1"

  parameters = {
    apiManagementServiceName  = "rpa-professional-api-portal-${var.env}"
    testServiceUrl            = "http://rpa-professional-api-${var.env}.service.core-compute-${var.env}.internal"
    claimServiceUrl           = "http://cmc-claim-store-${var.env}.service.core-compute-${var.env}.internal"
    claimDefinitionBody       = "  ${data.template_file.claim_api_def.rendered}"
    policy                    = "${file("template/api-policy.xml")}"
  }
}