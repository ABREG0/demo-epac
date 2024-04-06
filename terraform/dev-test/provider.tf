terraform {
  backend "azurerm" {
  }
  //   required_providers {
  //     azurerm = {
  //       source  = "hashicorp/azurerm"
  //       version = "=2.99.0"
  //     }
  //   }
}

provider "azurerm" {
  features {
  }
client_id       = "78f3f416-6a09-4f86-b04e-17d345a18ccc"
tenant_id            = "b4d1f2b8-7fc4-478e-9cd7-bb62ed356130"
subscription_id      = "d200e3b2-c0dc-4076-bd30-4ccccf05ffeb"
}

locals {
  private_dns_zone_ids = [
      "privatelink.monitor.azure.com","privatelink.oms.opinsights.azure.com","privatelink.ods.opinsights.azure.com","privatelink.agentsvc.azure-automation.net","privatelink.blob.core.windows.net"
    ]
  ampls_name = "ampls-001"
  ampls_rg = "rg-wus-ampls-001"
  dce_kind = ["Windows", "Linux"]
}
resource "azurerm_resource_group" "rg_ampls" {
  name = "rg-wus-ampls-001"
  location = "westus3"
}
module "ampls" {
  source = "../modules/azureMonitorPrivateLinkscope"
  name = "ampls-001"
  resource_group_name = azurerm_resource_group.rg_ampls.name

  depends_on = [ module.vnet_wus2, module.vnet_wus3, module.dns_wus2, module.dns_wus3 ]
}
resource "time_sleep" "wait_60_seconds" {
  depends_on = [azurerm_resource_group.rg_ampls, azurerm_resource_group.this_wus2, azurerm_resource_group.this_wus3]

  create_duration = "60s"
}
