
output "azurerm_resource_group" {
value = {for kk, kv in azurerm_resource_group.this : 
            "${kv.name}" => {
                "name" = kv.name
                "id" = kv.id
            }
    }
}
output "network_security_groups" {
  value = azurerm_network_security_group.this 
}
output "route_tables" {
  value = azurerm_route_table.this 
}

output "subnets" {
    value = {
        for kk, kv in flatten([
            for kk2, vv2 in module.vnets : [
                for k2, v2 in  vv2.subnets : {
                    name = v2.name
                    id = v2.resource_id
                } 
            ]
        ]) : "${kv.name}" => kv ...
    }
}

output "associate" {
  value = { for top_key, top_value in flatten([
                for net_key, net_v in local.vnet_object : [
                    for snet_k, snet_v in net_v.subnets : {
                        vnet = net_v.name
                        rt = snet_v.rt_key
                        nsg = snet_v.nsg_key
                        snet = snet_v.name
                        snet_id = module.vnets[net_v.name].subnets[snet_v.name].resource_id
                        nsg_id = azurerm_network_security_group.this[snet_v.nsg_key].id
                        rt_id = azurerm_route_table.this[snet_v.rt_key].id
                    } if snet_v.rt_key != null || snet_v.nsg_key != null
                ]
              ]) : "${top_value.snet}" => top_value
    }
}

output "subnets_object" {
  value = {
        for kk, kv in flatten([
            for k2, v2 in module.vnets : [
                for key, val in v2.subnets : {
                    "name" = val.name
                    "id" = val.resource_id
                }
            ]
        ]) : "${kv.name}" => kv ...
    }
}
output "vnet_object" {
  value = {
        for kk, kv in [
            for k2, v2 in module.vnets :  {
                    "name" = v2.name
                    "addressSpace" = v2.resource.body.properties.addressSpace
                    "peering" = v2.peerings
                }
        ] : "${kv.name}" => kv
    }
}
