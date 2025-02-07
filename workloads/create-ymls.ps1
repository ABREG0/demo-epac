
<# 
9/28/23: Version 1.0
This script is used to set the PostConfig properties for all YAML files in the specified directory.The script will loop over the YAML files and
do the following:
1. Check if the YAML file(s) exist in the specified directory
2. Create monitoring resource groups for each YAML file
3. Add the following properties to the YAML files:
    a. monitor_action_groups_enabled: true
    b. monitor_activity_log_alerts_enabled: true
    c. budget_creation_enabled: true
4. Create monitor_action_groups section for each YAML file
5. Create monitor_activity_log_alerts section for each YAML file


Omar A Omar
#>

##################################### INPUTS #####################################
param(
    [Parameter(Mandatory = $true)]
    [string]$inputYamlFilesDirectory
)

# Get a list of all YAML files in the specified directory
$yamlFiles = Get-ChildItem -Path $inputYamlFilesDirectory -Filter *.yml
# Log file directory and name
$logFilePath = Join-Path -Path $inputYamlFilesDirectory -ChildPath "PostConfigDomainLog.txt"

##################################### LOGGING #####################################
# Clear the log file,if it exists
if (Test-Path -Path $logFilePath) {
    Clear-Content -Path $logFilePath -Force
}
# Function to write real-time log messages to the console and log file
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$Message
    )
    process {
        # Check if the message is empty or null
        if (-not [string]::IsNullOrEmpty($Message)) {
            # Get the current timestamp
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            # Combine the timestamp and message
            $logMessage = "$timestamp - $Message"
            # Write the message to the console
            Write-Host $logMessage
            # Write the message to the log file
            $logMessage | Out-File -FilePath $logFilePath -Append
        }
    }
}
############################# PREREQUISITE MODULES ##################################
# Multiline log message
Write-Log @"

=====================================================
Checking module prerequisites...
=====================================================

"@

# Check if powershell-yaml is installed
$modulesToCheck = @("powershell-yaml")

foreach ($module in $modulesToCheck) {
    try {
        if ((Get-Module -Name $module -ListAvailable).Count -eq 0) {
            # Module is not installed, attempt to install it
            Write-Log "$module module is not installed. Installing module..."
            Install-Module -Name $module -Scope CurrentUser -Force
        }
        else {
            # Module is already installed
            Write-Log "$module module is already installed."
        }
    }
    catch {
        # Log an error message if an error occurs while installing the module
        Write-Log "Error installing $module module: $_"
    }
}
############################### VALIDATION #####################################
# Check if the YAML files directory exists
Write-Log @"

=====================================================
Validating file inputs...
=====================================================

"@
# Check if the YAML files directory exists and contains YAML files
if ($yamlFiles.Count -eq 0) {
    # Log an error message if the YAML files directory does not exist or does not contain YAML files
    Write-Log "Error: The YAML files directory does not exist or does not contain YAML files."
    Write-Log "Exiting script..."
    Exit
}
else {
    # Log a success message if the YAML files directory exists and contains YAML files
    Write-Log "The YAML files directory exists and contains $($yamlFiles.Count) YAML files."
}
################################# FUNCTIONS #####################################
# Function to get a specific property value from a YAML file
function Get-YamlPropertyValue {
    param (
        [string]$propertyName
    )

    try {
        # Load the YAML file
        $yamlData = Get-Content -Path $yamlFile.FullName | ConvertFrom-Yaml -Ordered
        # Split the property path into individual segments
        $pathSegments = $propertyName -split '\.'
        # Initialize a variable to navigate through the nested structure
        $currentNode = $yamlData
        # Iterate through the path segments to reach the desired depth
        for ($i = 0; $i -lt $pathSegments.Length; $i++) {
            $segment = $pathSegments[$i]

            # Check if the current segment exists in the current node
            if ($null -eq $currentNode.$segment) {
                # The property does not exist, return $null
                return $null
            }
            # Move to the next level
            $currentNode = $currentNode.$segment
        }
        # Return the value of the specified property
        return $currentNode
    }
    catch {
        # Log an error message if an error occurs
        Write-Host "Error: $($_.Exception.Message)"
        return $null
    }
}
# Define a hashtable to map geographic_area values to primary and secondary regions
$regionMappings = @{
    "us" = @{
        "Primary"   = "eastus";
        "Secondary" = "westus";
    };
    "uk" = @{
        "Primary"   = "uksouth";
        "Secondary" = "ukwest";
    };
    "ap" = @{
        "Primary"   = "eastasia";
        "Secondary" = "southeastasia";
    };
}
# Function to get Geographic area from the YAML file(s) and map it to the corrosponding primary and secondary regions accordingly 
function Convert-GeographicAreaToRegions {
    param (
        [hashtable]$regionMappings
    )
    try {
        # The property name to retrieve from the YAML file
        $propertyName = "geographic_area"
        # Call the Get-YamlPropertyValue function to retrieve the geographic_area value
        $geographicArea = Get-YamlPropertyValue -propertyName $propertyName

        if ($regionMappings.ContainsKey($geographicArea)) {
            $primaryRegion = $regionMappings[$geographicArea]["Primary"]
            $secondaryRegion = $regionMappings[$geographicArea]["Secondary"]

            return @($primaryRegion, $secondaryRegion)
        }
        else {
            # Log an error message if no mapping is found for the geographic_area
            Write-Log "No mapping found for geographic_area: $geographicArea"
            return $null  # Return null if no mapping is found
        }
    }
    catch {
        # Log an error message if an error occurs
        Write-Log "Error: $($_.Exception.Message)"
        return $null  # Return null in case of an error
    }
}
# Define a hashtable to map region name to region codes
$regionCodes = @{
    "eastus"        = "azr";
    "westus"        = "azc";
    "uksouth"       = "uks";
    "ukwest"        = "ukw";
    "eastasia"      = "eas";
    "southeastasia" = "sas";
}
function Convert-RegionsToRegionCodes {
    try {
        # Call the Convert-GeographicAreaToRegions function to get the primary and secondary regions
        $primaryAndSecondaryRegions = Convert-GeographicAreaToRegions -regionMappings $regionMappings
        # Check if the primary and secondary regions are returned
        if ($null -ne $primaryAndSecondaryRegions) {
            # Parse for the primary and secondary regions
            $primaryRegion = $primaryAndSecondaryRegions[0]
            $secondaryRegion = $primaryAndSecondaryRegions[1]

            # Check if the provided regions exist in the region codes hashtable
            if ($regionCodes.ContainsKey($primaryRegion) -and $regionCodes.ContainsKey($secondaryRegion)) {
                $primaryRegionCode = $regionCodes[$primaryRegion]
                $secondaryRegionCode = $regionCodes[$secondaryRegion]

                # Return the primary and secondary region codes as an array
                return @($primaryRegionCode, $secondaryRegionCode)
            }
            else {
                # Log an error message if a mapping is not found
                Write-Log "No mapping found for regions: $primaryRegion, $secondaryRegion"
                return $null  # Return null if no mapping is found
            }
        }
        else {
            # Log an error message if a mapping is not found
            Write-Log "No mapping found for regions: $primaryRegion, $secondaryRegion"
            return $null  # Return null if no mapping is found
        }
    }
    catch {
        # Log an error message if an error occurs
        Write-Log "Error: $($_.Exception.Message)"
        return $null  # Return null in case of an error
    }
}
# Function to create a set of monitoring resource groups and monitor_action_groups for each YAML file
function Set-MonitoringResourceGroups {
    try {
        # Get the primary and secondary regions based on the geographic_area
        $regions = Convert-GeographicAreaToRegions -yamlFile $yamlFile -regionMappings $regionMappings

        # Check if the primary and secondary regions are returned, and if so, parse them. Otherwise, log an error message
        if ($null -ne $regions) {
            $primaryRegion = $regions[0]
            $secondaryRegion = $regions[1]
        }
        else {
            # Log an error message if a mapping is not found
            Write-Log "No mapping found for regions: $primaryRegion, $secondaryRegion"
            # exit the script
            Exit
        }
        # Get the primary and secondary region codes based on the primary and secondary regions
        $regionCodes = Convert-RegionsToRegionCodes
        # Get the primary and secondary region codes
        $primaryRegionCode = $regionCodes[0]
        $secondaryRegionCode = $regionCodes[1]

        # Logging
        Write-Log "Primary region: $primaryRegion and Secondary region: $secondaryRegion"
        Write-Log "Primary region code: $primaryRegionCode and Secondary region code: $secondaryRegionCode"


        # Get the environment_subtype from the YAML file
        $environmentSubtype = Get-YamlPropertyValue -yamlFile $yamlFiles -propertyName "environment_subtype"
        # If the environment_subtype is null, exit the script
        if ($null -eq $environmentSubtype) {
            # Log an error message if the environment_subtype is null
            Write-Log "Error: The environment_subtype is null."
            # exit the script
            Exit
        }

        Write-Log "Environment subtype: $environmentSubtype"

        # Add the monitoring resource groups once
        $monitoringResourceGroupNamePrimary = "monitoring_rg_primary"
        $monitoringResourceGroupNameSecondary = "monitoring_rg_secondary"
        $monitoringResourceGroupPrimary = [ordered]@{
            "name"     = "$primaryRegionCode-monitoring-rg-01-$environmentSubtype"
            "location" = $primaryRegion
        }
        $monitoringResourceGroupSecondary = [ordered]@{
            "name"     = "$secondaryRegionCode-monitoring-rg-01-$environmentSubtype"
            "location" = $secondaryRegion
        }

        # Add the resource groups to the YAML file
        $yamlData = Get-Content -Path $yamlFile.FullName | ConvertFrom-Yaml -Ordered
        if (-not $yamlData.PSObject.Properties.Match("resource_groups")) {
            $yamlData | Add-Member -MemberType NoteProperty -Name "resource_groups" -Value [ordered]@ {}
        }      
        # Initialize resource_groups as a hashtable if it doesn't exist
        if ($null -eq $yamlData.resource_groups) {
            $yamlData.resource_groups = [ordered]@{}
        }       
        # Add the monitoring resource groups to the YAML file
        $yamlData.resource_groups[$monitoringResourceGroupNamePrimary] = $monitoringResourceGroupPrimary
        $yamlData.resource_groups[$monitoringResourceGroupNameSecondary] = $monitoringResourceGroupSecondary
        
        # Save the updated YAML data back to the YAML file
        $yamlData | ConvertTo-Yaml | Set-Content -Path $yamlFile.FullName
        # Logging
        Write-Log "Added monitoring resource groups successfully."
        
        # Get the contact_email_address from the YAML file
        $contactEmailAddress = Get-YamlPropertyValue -yamlFile $yamlFile -propertyName "contact_email_address"
        # Get the alternative_email_addresses from the YAML file
        $alternativeEmailAddresses = Get-YamlPropertyValue -yamlFile $yamlFile -propertyName "alternative_email_addresses"

        # Create the monitor_action_groups section to the YAML file
        $monitorActionGroups = [ordered]@{
            "admin_default_action_group" = [ordered]@{
                "name"                = "admin-action-group"
                "resource_group_name" = $monitoringResourceGroupPrimary.name
                "short_name"          = "azr-mt-rg-01-$environmentSubtype"
                "email_receivers"     = @()
            }
        }
        # Add contact email receivers to the monitor_action_groups section
        $monitorActionGroups["admin_default_action_group"]["email_receivers"] += [ordered]@{
            "name"          = "admin-default-action-group"
            "email_address" = $contactEmailAddress
        }
        

        # Loop through the alternative email addresses and add them to the YAML file
        # foreach ($alternativeEmailAddress in $alternativeEmailAddresses) {
        #     $indexFormatted = "{0:D2}" -f ($index + 1)  # Format index as two digits (e.g., 01, 02, ...)
            
        #     $monitorActionGroups["admin_default_action_group"]["email_receivers"] += [ordered]@{
        #         "name"          = "alternative_email_address_$indexFormatted"
        #         "email_address" = $alternativeEmailAddress
        #     }
        # }

        # Loop through the alternative email addresses and add them to the YAML file
        foreach ($index in 0..($alternativeEmailAddresses.Count - 1)) {
            $indexFormatted = "{0:D2}" -f ($index + 1)  # Format index as two digits (e.g., 01, 02, ...)
            
            $monitorActionGroups["admin_default_action_group"]["email_receivers"] += [ordered]@{
                "name"          = "alternative_email_address_$indexFormatted"
                "email_address" = $alternativeEmailAddresses[$index]
            }
        }


        # Add the monitor_action_groups section to the YAML file if it doesn't exist
        if (-not $yamlData.PSObject.Properties.Match("monitor_action_groups")) {
            $yamlData | Add-Member -MemberType NoteProperty -Name "monitor_action_groups" -Value [ordered]@ {}
        }
        # Initialize monitor_action_groups as a hashtable if it doesn't exist
        if ($null -eq $yamlData.monitor_action_groups) {
            $yamlData.monitor_action_groups = [ordered]@{}
        }
        # Add the monitor_action_groups section to the YAML file
        $yamlData.monitor_action_groups = $monitorActionGroups

        # Save the updated YAML data back to the YAML file
        $yamlData | ConvertTo-Yaml | Set-Content -Path $yamlFile.FullName
        # Logging
        Write-Log "Added monitor_action_groups section to the YAML file."
    
    }
    catch {
        # Log an error message if an error occurs
        Write-Log "Error: $($_.Exception.Message)"
    }
}
# Function to create monitor_activity_log_alerts for each YAML file
function Set-MonitorActivityLogAlerts {
    try {
        # Get the primary and secondary regions based on the geographic_area
        $regions = Convert-GeographicAreaToRegions -yamlFile $yamlFile -regionMappings $regionMappings

        # Check if the primary and secondary regions are returned, and if so, parse them. Otherwise, log an error message
        if ($null -ne $regions) {
            $primaryRegion = $regions[0]
            $secondaryRegion = $regions[1]
        }
        else {
            # Log an error message if a mapping is not found
            Write-Log "No mapping found for regions: $primaryRegion, $secondaryRegion"
            # exit the script
            Exit
        }
        # # Get the primary and secondary region codes based on the primary and secondary regions
        # $regionCodes = Convert-RegionsToRegionCodes
        # # Get the primary and secondary region codes
        # $primaryRegionCode = $regionCodes[0]
        # $secondaryRegionCode = $regionCodes[1]

        # # Logging
        # Write-Log "Primary region: $primaryRegion and Secondary region: $secondaryRegion"
        # Write-Log "Primary region code: $primaryRegionCode and Secondary region code: $secondaryRegionCode"


        # Load the existing YAML file
        $yamlData = Get-Content -Path $yamlFile.FullName | ConvertFrom-Yaml -Ordered

        # Create the monitor_activity_log_alerts section to the YAML file
        $monitorActivityLogAlerts = [ordered]@{
            "default_service_alert_primary" = [ordered]@{
                "name"              = "default_service_alert_primary"
                "description"       = "Default alert for service health events"
                "scope_lookup_keys" = "SUBSCRIPTION_ID_PLACEHOLDER"
                "enabled"           = $true
                "criteria"          = [ordered]@{
                    "category"       = "ServiceHealth"
                    "service_health" = [ordered]@{
                        "events"    = "EVENTS_PLACEHOLDER"
                        "locations" = "LOCATIONS_PLACEHOLDER"
                    }
                }
                "actions"           = @(
                    [ordered]@{
                        "action_group_lookup_key" = "admin-action-group"
                        "webhook_properties"      = [ordered]@{}
                    }
                )
            }
        }

        # Initialize monitor_activity_log_alerts as a hashtable if it doesn't exist
        if (-not $yamlData.PSObject.Properties.Match("monitor_activity_log_alerts")) {
            Write-Log "DEBUG: Initializing monitor_activity_log_alerts."
            $yamlData | Add-Member -MemberType NoteProperty -Name "monitor_activity_log_alerts" -Value [ordered]@ {}
        }

        # Add the monitor_activity_log_alerts section to the YAML file
        $yamlData.monitor_activity_log_alerts = $monitorActivityLogAlerts

        # Get the actual values for events and locations
        $subscriptionId = '["subscription_id"]'
        $actualEvents = "[Incident, Maintenance, Informational, ActionRequired, Security]"
        $actualLocations = "[$primaryRegion, $secondaryRegion]"
    
        # Replace the placeholders with the actual values
        $yamlData.monitor_activity_log_alerts.default_service_alert_primary.scope_lookup_keys = $subscriptionId
        $yamlData.monitor_activity_log_alerts.default_service_alert_primary.criteria.service_health.events = $actualEvents
        $yamlData.monitor_activity_log_alerts.default_service_alert_primary.criteria.service_health.locations = $actualLocations

        
        try {
            # Convert to YAML and replace single quotes globally
            $yamlString = ($yamlData | ConvertTo-Yaml) -replace "'", ''
        
            # Save the updated YAML data back to the YAML file
            $yamlString | Set-Content -Path $yamlFile.FullName -Force
            Write-Log "Added monitor_activity_log_alerts section to the YAML file."
        }
        catch {
            Write-Log "Error during YAML conversion or file write: $_"
            # You may want to add more specific error handling or logging here.
        }

    }
    catch {
        # Log an error message if an error occurs
        Write-Log "Error: $($_.Exception.Message)"
    }
}
# propertyarray to add properties to the YAML files
$propertiesArray = @(
    @{ Path = "monitor_action_groups_enabled"; Value = $true },
    @{ Path = "monitor_activity_log_alerts_enabled"; Value = $true },
    @{ Path = "budget_creation_enabled"; Value = $true }
)
# Function to add properties to the YAML files
function Add-Properties {
    try {
        # Load the YAML file
        $yamlData = Get-Content -Path $yamlFile.FullName | ConvertFrom-Yaml -Ordered
        # Loop through the properties in the $propertiesArray
        foreach ($property in $propertiesArray) {
            $propertyPath = $property.Path
            $propertyValue = $property.Value
            # Split the property path into individual segments
            $pathSegments = $propertyPath -split '\.'
            # Initialize a variable to navigate through the nested structure
            $currentNode = $yamlData
            # Iterate through the path segments to reach the desired depth
            for ($i = 0; $i -lt $pathSegments.Length - 1; $i++) {
                $segment = $pathSegments[$i]
                # Check if the current segment exists in the current node
                if ($null -eq $currentNode.$segment) {
                    # Create a new node if it doesn't exist
                    $currentNode | Add-Member -MemberType NoteProperty -Name $segment -Value [ordered]@ {}
                }
                # Move to the next level
                $currentNode = $currentNode.$segment
            }
            # Check if the property is within a list and if the current node's property is also a list
            if ($propertyValue -is [System.Collections.IEnumerable] -and $currentNode.$($pathSegments[-1]) -is [System.Collections.IList]) {
                # Clear the existing list if it's a list
                $currentNode.$($pathSegments[-1]).Clear()
                # Add the new items to the list
                $currentNode.$($pathSegments[-1]).AddRange($propertyValue)
            }
            else {
                # Set the value at the desired depth
                $currentNode.$($pathSegments[-1]) = $propertyValue
            }
        }
        # Save the updated YAML data back to the file
        $yamlData | ConvertTo-Yaml | Set-Content -Path $yamlFile.FullName
        Write-Log "Updated properties in $($yamlFile.Name)"
    }
    catch {
        # Write-Log "Error updating $($filePath): $_"
        Write-Log "Error adding the property '$property' to $($yamlFile.Name): $_"
    }
}
################################# MAIN FUNCTION #####################################
# Main function
function Set-PostConfigProperties {
    try {
        # Loop over the YAML files
        foreach ($yamlFile in $yamlFiles) {
            # Logging
            Write-Log @"

=====================================================
Processing YAML file: $($yamlFile.Name)
=====================================================

"@
            # Call the Set-MonitoringResourceGroups function to create the monitoring resource groups
            Set-MonitoringResourceGroups #yamlFile $yamlFile -regionMappings $regionMappings -regionCodes $regionCodes
            # Call the Add-Properties function to add the properties to the YAML files
            Add-Properties #yamlFile $yamlFile -propertiesArray $propertiesArray
            # Call the Set-MonitorActivityLogAlerts function to create the monitor_activity_log_alerts
            Set-MonitorActivityLogAlerts #NOTE: call this function last
        }
    }
    catch {
        # Log an error message if an error occurs
        Write-Log "Error: $($_.Exception.Message)"
    }
}
################################### EXECUTION ####################################
# Call the Set-PostConfigProperties function to set the PostConfig properties
Set-PostConfigProperties -yamlFiles $yamlFiles # -regionMappings $regionMappings -regionCodes $regionCodes
