output "microserviceName" {
  value = "${var.component}"
}

output "subscription-id" {
  value = "${var.subscription}"
}

output "resource-group-name" {
  value = "${azurerm_resource_group.rg.name}"
}

output "service-name" {
  value = "${local.apiManagementServiceName}"
}
