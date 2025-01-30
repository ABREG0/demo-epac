terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azapi" {
  #   enable_hcl_output_for_data_source = true
}
variable "resource_id" {
  type = string
}
data "azapi_resource" "this" {
  resource_id = var.resource_id
  type        = "Microsoft.Network/privateEndpoints@2021-05-01"

  response_export_values = ["properties.customDnsConfigs", "properties.customDnsConfigs.ipAddresses"]
}

output "this" {
  value = data.azapi_resource.this

}
output "fqdn" {
  value = data.azapi_resource.this.output.properties.customDnsConfigs[0].fqdn
}
output "ipAddresses" {
  value = data.azapi_resource.this.output.properties.customDnsConfigs[0].ipAddresses
}