output "microserviceName" {
  value = "${var.component}"
}

output "subscriptionId" {
  value = "${var.subscription}"
}

output "resourceGroupName" {
  value = "${azurerm_resource_group.rg.name}"
}

output "serviceName" {
  value = "${local.apiManagementServiceName}"
}

output "vaultName" {
  value = "${module.local_key_vault.key_vault_name}"
}
