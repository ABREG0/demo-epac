locals {
    
    nsg_id = {for kk, kv in azurerm_network_security_group.this : 
                "${kv.name}" => {
                    "name" = kv.name
                    "id" = kv.id
                }
    }
    rt_id = {for kk, kv in azurerm_route_table.this : 
                "${kv.name}" => {
                    "name" = kv.name
                    "id" = kv.id
                }
    }
    vnet_object = flatten([
                for net_key, net_v in var.hub_connection : [
                    for snet_k, snet_v in net_v.resources.virtual_networks : {
                        resource_group_name = net_key
                        location = net_v.location
                        namespace = net_v.namespace
                        tags = net_v.tags
                        name = snet_v.name
                        virtual_network_address_space = snet_v.virtual_network_address_space
                        subnets = snet_v.subnets
                    }
                ]
                
    ])
    creating_nested_objects_vnets2 = flatten([
        for top_key, top_value in var.hub_connection :
        [ 
            for key, value in top_value.resources.virtual_networks: {
                resource_group_name = top_key
                location = top_value.location
                namespace = top_value.namespace
                tags = top_value.tags
                name = value.name
                virtual_network_address_space = value.virtual_network_address_space
                subnets = value.subnets
                }
        ]
    ])
    
    creating_nested_objects_rt2 = flatten([
        for top_key, top_value in var.hub_connection :
        [ 
            for key, value in top_value.resources.route_tables: {
                resource_group_name = top_key
                namespace = top_value.namespace
                # virtual_network_name = top_value.resources.virtual_networks.name
                location = top_value.location
                name = value.name
                rules = value.rules
                }
        ]
    ])

    creating_nested_objects_nsg2 = flatten([
        for top_key, top_value in var.hub_connection :
        [ 
            for key, value in top_value.resources.network_security_groups: {
                resource_group_name = top_key
                namespace = top_value.namespace
                # virtual_network_name = top_value.resources.virtual_networks.name
                location = top_value.location
                name = value.name
                rules = value.rules
                }
        ]
    ])
    resource_groups = [
     for top_key, top_value in var.hub_connection :
        {  
            resource_group_name = top_key
            location = top_value.location
            tags = top_value.tags
        }
    # for item_key, item_value in var.hub_connection : 
    # item_key => item_key # item_value.resources
    # if resource.west_fw_shared_wus2 &&
    # contains(["connectivity", "ddos", "dns"], resource.west_fw_shared_wus2)
    ]
    resource_groups2 = {
     for top_key, top_value in var.hub_connection :
        "RGs" => {  
            resource_group_name = top_key
            location = top_value.location
            tags = top_value.tags
        }...
    # for item_key, item_value in var.hub_connection : 
    # item_key => item_key # item_value.resources
    # if resource.west_fw_shared_wus2 &&
    # contains(["connectivity", "ddos", "dns"], resource.west_fw_shared_wus2)
    }
    # object variable to list
    flats = { for top_key, top_value in [
                for index_key, kv in var.hub_connection : [
                    for rk, rv in kv.resources : {
                        "${rk}" = rv
                        resource_group_name         = index_key
                        location = kv.location
                    }
                ]
              ] : "${top_key}" => top_value
    }

    creating_nested_objects_resources = {
        for top_key, top_value in var.hub_connection :
        top_key => {  
            for k, v in top_value.resources: k => {
                    resource_group_name = top_key
                    location = top_value.location
                    tags = top_value.tags
                    "${k}" = v
                }
        }
    }
    creating_nested_objects-00 = {
        for top_key, top_value in var.hub_connection :
        top_key => {  
                resource_group_name = top_key
                location = top_value.location
                tags = top_value.tags
                "all_resources" = top_value.resources
        }
    }
    creating_nested_objects_vnets = {
        for top_key, top_value in var.hub_connection :
        top_key => {  
                resource_group_name = top_key
                location = top_value.location
                tags = top_value.tags
                "vnets" = top_value.resources.virtual_networks
        }
    }
    creating_nested_objects_nsg = {
        for top_key, top_value in var.hub_connection :
        top_key => {  
                resource_group_name = top_key
                # virtual_network_name = top_value.resources.virtual_networks.name
                location = top_value.location
                tags = top_value.tags
                "nsg" = top_value.resources.network_security_groups
        }
    }
    creating_nested_objects_rt = {
        for top_key, top_value in var.hub_connection :
        top_key => {  
                resource_group_name = top_key
                # virtual_network_name = top_value.resources.virtual_networks.name
                location = top_value.location
                tags = top_value.tags
                "rt" = top_value.resources.route_tables
        }
    }
    /*
    creating_nested_objects_subnets = {
        for top_key, top_value in var.hub_connection :
        top_key => {  
                resource_group_name = top_key
                virtual_network_name = top_value.resources.virtual_networks.name
                location = top_value.location
                tags = top_value.tags
                "subnets" = {
                                         for top_key, top_value in top_value.resources.virtual_networks.subnets:
                                            top_key => {
                                                name             = top_value.name
                                                address_prefixes = top_value.address_prefixes
                                                nsg_id = {for kk, kv in azurerm_network_security_group.this :
                                                                        "id" => kv.id...
                                                                        if kv.name == top_value.name
                                                                    }
                                            }
                                        }
        }
    }
    */
    # subnets = { for subnet in var.hub_connection.ohemr-rg-core_fw-shared-wus2-002.resources.virtual_networks.subnets : subnet.name => subnet }

    vnets = [ for rgK, rgV in var.hub_connection : {
      for res_k, res_v in rgV.resources.virtual_networks : #{res_k = res_v} 
            "${res_k}" => res_v
        # if res_k == "virtual_networks"
    } 
    ]
    top_key = { for rgK, rgV in  {
      for res_k, res_v in var.hub_connection :
            res_k => "${res_k}"
        # if res_k == "virtual_networks"
        } : "topKey" =>  rgV...
    }
}
