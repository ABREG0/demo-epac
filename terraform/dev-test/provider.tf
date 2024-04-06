terraform {
  backend "azurerm" {
    resource_group_name  = "hub-tier0"
    storage_account_name = "mywestus3sattt"
    container_name       = "terraform"
    key                  = "dev.tfstate"
    use_oidc = true
  }
  //   required_providers {
  //     azurerm = {
  //       source  = "hashicorp/azurerm"
  //       version = "=2.99.0"
  //     }
  //   }
}

provider "azurerm" {
  features {}
  
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

  # depends_on = [ module.vnet_wus2, module.vnet_wus3, module.dns_wus2, module.dns_wus3 ]
}
resource "time_sleep" "wait_60_seconds" {
  depends_on = [azurerm_resource_group.rg_ampls, azurerm_resource_group.this_wus2, azurerm_resource_group.this_wus3]

  create_duration = "60s"
}
