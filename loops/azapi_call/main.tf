

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  for_each = { for kk, kv in local.resource_groups : kk => kv
  } # {for kk, kv in local.resource_groups.RGs : kk => kv}
  location = each.value.location
  name     = each.value.resource_group_name
}

module "vnets" {
  depends_on = [azurerm_resource_group.this, ]
  for_each   = merge({ for kk, kv in local.vnet_object : "${kv.name}" => kv }) #local.creating_nested_objects_vnets2 # {for kk, kv in local.creating_nested_objects_vnets2 : kk => kv }
  source     = "github.com/elsalvos-org/terraform-azurerm-avm-res-network-virtualnetwork"

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  address_space = each.value.virtual_network_address_space

  dns_servers = {
    dns_servers = ["8.8.8.8"]
  }
  flow_timeout_in_minutes = 30

  subnets = each.value.subnets

  /*
        ddos_protection_plan = {
            id = azurerm_network_ddos_protection_plan.this.id
            # due to resource cost
            enable = false
        }

        role_assignments = {
            role1 = {
            principal_id               = azurerm_user_assigned_identity.this.principal_id
            role_definition_id_or_name = "Contributor"
            }
        }

        enable_vm_protection = true

        encryption = {
            enabled = true
            #enforcement = "DropUnencrypted"  # NOTE: This preview feature requires approval, leaving off in example: Microsoft.Network/AllowDropUnecryptedVnet
            enforcement = "AllowUnencrypted"
        }

        diagnostic_settings = {
            sendToLogAnalytics = {
            name                           = "sendToLogAnalytics"
            workspace_resource_id          = azurerm_log_analytics_workspace.this.id
            log_analytics_destination_type = "Dedicated"
            }
        }
        */
}

#Creating a Route Table with a unique name in the specified location.
resource "azurerm_route_table" "this" {
  depends_on = [module.vnets, module.vnets, ]
  for_each = { for kk, kv in local.creating_nested_objects_rt2 : kv.name => kv
  }

  name                = format("%s-${each.value.name}", "${each.value.namespace}-rt")
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_subnet_route_table_association" "this" {
  depends_on = [azurerm_route_table.this]
  for_each = { for top_key, top_value in flatten([
    for net_key, net_v in local.creating_nested_objects_vnets2 : [
      for snet_k, snet_v in net_v.subnets : {
        snet_id = module.vnets[net_v.name].subnets[snet_v.name].resource_id
        rt_id   = azurerm_route_table.this[snet_v.rt_key].id
      } if snet_v.rt_key != null || snet_v.nsg_key != null
    ]
    ]) : "${top_key}" => top_value
  }
  subnet_id      = each.value.snet_id
  route_table_id = each.value.rt_id
}

resource "azurerm_network_security_group" "this" {
  depends_on = [azurerm_subnet_route_table_association.this]
  for_each = { for kk, kv in local.creating_nested_objects_nsg2 : kv.name => kv
  }
  location            = each.value.location
  name                = format("%s-${each.value.name}", "${each.value.namespace}-nsg") # each.value.name #
  resource_group_name = each.value.resource_group_name

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "443"
    direction                  = "Inbound"
    name                       = "AllowInboundHTTPS"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = "10.2.3.1" # jsondecode(data.http.public_ip.response_body).ip
    source_port_range          = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "this" {
  depends_on = [azurerm_network_security_group.this]
  for_each = { for top_key, top_value in flatten([
    for net_key, net_v in local.creating_nested_objects_vnets2 : [
      for snet_k, snet_v in net_v.subnets : {
        snet_id = module.vnets[net_v.name].subnets[snet_v.name].resource_id
        nsg_id  = azurerm_network_security_group.this[snet_v.nsg_key].id
      } if snet_v.rt_key != null || snet_v.nsg_key != null
    ]
    ]) : "${top_key}" => top_value
  }
  subnet_id                 = each.value.snet_id
  network_security_group_id = each.value.nsg_id

}

/*
## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

*/