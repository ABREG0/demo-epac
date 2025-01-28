
Get-AzPolicyAssignment -Scope '/providers/Microsoft.Management/managementGroups/epac-dev-gh' | Remove-AzPolicyAssignment
Get-AzPolicyDefinition -ManagementGroupName 'epac-dev-gh' -Custom | Remove-AzPolicyDefinition
Get-AzPolicyDefinition -ManagementGroupName 'epac-dev-gh' -Custom | Remove-AzPolicyDefinition -Force
Get-AzPolicySetDefinition -ManagementGroupName 'epac-dev-gh' -Custom  | Remove-AzPolicySetDefinition -Force
Get-AzPolicyDefinition -ManagementGroupName 'epac-dev-gh' -Custom | Remove-AzPolicyDefinition -Force