variable "resource_id" {
  type = string
}
locals {
  # flatten ensures that this local value is a flat list of objects, rather
  # than a list of lists of objects.
  network_subnets = flatten([
    for network_key, network in var.networks : [
      for subnet_key, subnet in network.subnets : {
        vnet_name           = network_key
        resource_group_name = network.resource_group_name
        location            = network.location
        subnet_name         = subnet_key
        # vnet_name  = network.name # azurerm_virtual_network.this[network_key].name
        subnet_address_space = subnet.address_space
      }
    ]
  ])
}
output "network_subnets" {
  value = local.network_subnets
}
output "resource_id" {
  value = var.resource_id
}
variable "networks" {
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    address_space       = string
    subnets = map(object({
      name                = string
      resource_group_name = string
      location            = string
      address_space       = string
    }))
  }))
  default = {
    "dbServers" = {
      name                = "dbServers"
      resource_group_name = "rg-001"
      location            = "westus3"
      address_space       = "10.1.0.0/16"
      subnets = {
        "db1-subnet" = {
          name                = "db1"
          resource_group_name = "rg-001"
          location            = "westus3"
          address_space       = "10.1.0.1/16"
        }
        "db2-subnet" = {
          name                = "db2"
          resource_group_name = "rg-001"
          location            = "westus3"
          address_space       = "10.1.0.2/16"
        }
      }
    },
    "webServers" = {
      name                = "webServers"
      resource_group_name = "rg-001"
      location            = "westus3"
      address_space       = "10.1.1.0/16"
      subnets = {
        "webserver-subnet" = {
          name                = "webserver-subnet"
          resource_group_name = "rg-001"
          location            = "westus3"
          address_space       = "10.1.1.1/16"
        }
        "email-server-subnet" = {
          name                = "email-server-subnet"
          resource_group_name = "rg-001"
          location            = "westus3"
          address_space       = "10.1.1.2/16"
        }
      }
    }
    "appServers-subnet" = {
      name                = "appServers"
      resource_group_name = "rg-001"
      location            = "westus3"
      address_space       = "10.1.2.0/16"
      subnets = {
        "app1-subnet" = {
          name                = "app1"
          resource_group_name = "rg-001"
          location            = "westus3"
          address_space       = "10.1.2.1/16"
        }
      }
    }
  }
}
