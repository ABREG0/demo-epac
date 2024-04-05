variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "tags" {
  type = map(any)
  default = {}
}
resource "azurerm_monitor_private_link_scope" "ampls" {
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

output "id" {
  value = azurerm_monitor_private_link_scope.ampls.id
}
output "name" {
  value = azurerm_monitor_private_link_scope.ampls.name
}
output "resource_group_name" {
  value = azurerm_monitor_private_link_scope.ampls.resource_group_name
}