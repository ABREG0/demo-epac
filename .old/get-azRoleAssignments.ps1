# cabrego 2021
# Requires PowerShell core and lastest Az module 

# add your tenant id here... 
$TenantID = 'b4d1f2b8-7fc4-478e-9cd7-bb62ed356130'

# Disconnect exiting connections and clearing contexts.
Write-Output "Clearing existing Azure connection `n"
Disconnect-AzAccount -ContextName 'myCont' | Out-Null

Write-Output "Clearing existing Azure context `n"
get-azcontext -ListAvailable | ForEach-Object { $_ | remove-azcontext -Force -Verbose | Out-Null } #remove all connected content

Write-Output "`nClearing of existing connection and context completed. `n"

$scriptPath = $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

Try {
    #Connect-AzAd
    #connect to azure and setup context name

    $ConnectToTentant = Connect-AzAccount -Tenant $TenantID -ContextName 'MGMTenant' -Force -ErrorAction Stop 

    #$ConnectToTentant.Context

    #Select subscription to build
    $GetSubscriptions = Get-AzSubscription |  Out-GridView -Title "Select Subscription to build" -PassThru 

}
catch {

    Write-warning "Error When trying to connct to tenant...`n"

    $_ ;

    exit 
    #$_.Exception.Message
} 

$HTRoleAssignments = ''; $HTRoleAssignments = @()

foreach ($GetSubscription in $GetSubscriptions) {

    Try {
        #getting subscription object to set context
        $GetSubscriptionObj = get-azsubscription -SubscriptionId $GetSubscription.Id -ErrorAction Stop  | Where-Object { ($_.state -eq 'enabled') }

        #Set context for subscription being built
        $SubscriptionContextReturn = Set-AzContext -Subscription $GetSubscriptionObj.id
		 
    }
	   catch [Exception] { 

        Write-warning "Error Message: `n$_ "

        $_

    }
    
		Write-Host "Subscription Name: $($GetSubscriptionObj.Name) `n"
		$Assignments = ''; $Assignments = Get-AzRoleAssignment #| ? {($_.RoleDefinitionName -eq 'owner') -or ($_.RoleDefinitionName -eq 'Contributor')} #-RoleDefinitionName "owner"
		
		foreach ($Assignment in $Assignments){
			#build web hash table PSObject
			if($null -ne $Assignment.DisplayName){
				$groupMembers = '';
                
                Write-Host $_.Exception.Message
                if($Assignment.ObjectType -eq 'Group'){
                    try{
                        $Assignment.DisplayName
                        $members = '';
                        [array]$members = Get-AzAdGroup -DisplayName $($Assignment.DisplayName) | Get-AzAdGroupMember
                        $groupMembers = $members.DisplayName -join ';'
                        
                        }
                        catch{
                        Write-Host $_.Exception.Message
                        }
                    }
                     else{
                        $Assignment.DisplayName
                         $groupMembers = '' #empty if is not a group
                     }
						
                }
                
			$RolesAssignments = '';	$RolesAssignments = new-object PSObject 
			$RolesAssignments | add-member -membertype NoteProperty -name "Subscription" -Value $GetSubscriptionObj.Name
            $RolesAssignments | add-member -membertype NoteProperty -name "DisplayName" -Value $Assignment.DisplayName
            $RolesAssignments | add-member -membertype NoteProperty -name "Scope" -Value $Assignment.scope 
			$RolesAssignments | add-member -membertype NoteProperty -name "GroupMembers" -Value $groupMembers
	    	$RolesAssignments | add-member -membertype NoteProperty -name "RoleDefinitionName" -Value $Assignment.RoleDefinitionName
			$RolesAssignments | add-member -membertype NoteProperty -name "SignInName" -Value $Assignment.SignInName
			$RolesAssignments | add-member -membertype NoteProperty -name "ObjectType" -Value $Assignment.ObjectType

			$HTRoleAssignments += $RolesAssignments
			
		}
		
}

$HTRoleAssignments | ConvertTo-Csv -NoTypeInformation | Out-File "$($scriptPath)\AllRoleAssigned$(get-date -f yyyyddmm-hhmmss).csv" -NoClobber -Append


###########################################################################################
Try {
    #Connect-AzAd
    #connect to azure and setup context name

    #$ConnectToTentant = Connect-AzAccount -Tenant $TenantID -ContextName 'MGMTenant' -Force -ErrorAction Stop 

    #$ConnectToTentant.Context

    #Select subscription to build
    $GetManagementGroups = Get-AzManagementGroup |  Out-GridView -Title "Select Management groups" -PassThru 

}
catch {

    Write-warning "Error When trying to connct to tenant...`n"

    $_ ;

    exit 
    #$_.Exception.Message
} 

$HTRoleAssignments_mg = ''; $HTRoleAssignments_mg = @()

foreach ($GetManagementGroup in $GetManagementGroups) {

    Try {
        #getting subscription object to set context
        $GetManagementGroupObj = get-AzManagementGroup -GroupName $($GetManagementGroup.name) -ErrorAction Stop #  | Where-Object { ($_.state -eq 'enabled') }

        #Set context for subscription being built
        # $SubscriptionContextReturn = Set-AzContext -Subscription $GetManagementGroupObj.id
		 
    }
	   catch [Exception] { 

        Write-warning "Error Message: `n$_ "

        $_

    }
    
		Write-Host "Management Group Name: $($GetManagementGroupObj.Name) `n"
		$Assignments = ''; $Assignments = Get-AzRoleAssignment -scope $($GetManagementGroup.id) #| ? {($_.RoleDefinitionName -eq 'owner') -or ($_.RoleDefinitionName -eq 'Contributor')} #-RoleDefinitionName "owner"
		
		foreach ($Assignment in $Assignments){
			#build web hash table PSObject
			if($null -ne $Assignment.DisplayName){
				$groupMembers = '';
                
                Write-Host $_.Exception.Message
                if($Assignment.ObjectType -eq 'Group'){
                    try{
                        $Assignment.DisplayName
                        $members = '';
                        [array]$members = Get-AzAdGroup -DisplayName $($Assignment.DisplayName) | Get-AzAdGroupMember
                        $groupMembers = $members.DisplayName -join ';'
                        
                        }
                        catch{
                        Write-Host $_.Exception.Message
                        }
                    }
                     else{
                        $Assignment.DisplayName
                         $groupMembers = '' #empty if is not a group
                     }
						
                }
                
			$RolesAssignments = '';	$RolesAssignments = new-object PSObject 
			$RolesAssignments | add-member -membertype NoteProperty -name "ManagementGroup" -Value $GetManagementGroupObj.Name
            $RolesAssignments | add-member -membertype NoteProperty -name "DisplayName" -Value $Assignment.DisplayName
            $RolesAssignments | add-member -membertype NoteProperty -name "Scope" -Value $Assignment.scope 
			$RolesAssignments | add-member -membertype NoteProperty -name "GroupMembers" -Value $groupMembers
	    	$RolesAssignments | add-member -membertype NoteProperty -name "RoleDefinitionName" -Value $Assignment.RoleDefinitionName
			$RolesAssignments | add-member -membertype NoteProperty -name "SignInName" -Value $Assignment.SignInName
			$RolesAssignments | add-member -membertype NoteProperty -name "ObjectType" -Value $Assignment.ObjectType

			$HTRoleAssignments_mg += $RolesAssignments
			
		}
		
}
$HTRoleAssignments_mg | ConvertTo-Csv -NoTypeInformation | Out-File "$($scriptPath)\mgAllRoleAssigned$(get-date -f yyyyddmm-hhmmss).csv" -NoClobber -Append
