# Auto module testing worflows

This solution uses OIDC for SPN authentication. github environment to add variables

copy the workflow below to the module repo you are testing. 

1. create a caller workflow: .github\workflows\_example-apply-caller.yml
   1. update information on caller yml file
   2. cloud_provider: azure
        Create variables named ***'AZURE_CLIENT_ID'*** ***'AZURE_TENANT_ID'*** or replace the names of these veriables with your own custom created vars. 
   ```
      azure_client_id: **[replace me]** # app id
      azure_tenant_id: **[replace me]** # entra id tenant

      azure_client_id: ${{ needs.preConfig.outputs.AZURE_CLIENT_ID }} # STATIC  VALUES CAN BE ADDED HERE. if no access to variables is in place.
      azure_tenant_id: ${{ needs.preConfig.outputs.AZURE_TENANT_ID }} # STATIC  VALUES CAN BE ADDED HERE. if no access to variables is in place.
    ```
      environment_name: sbx
      optfile_path: **optfiles/sbx.json** # optfiles/envName.json
      optfile_runner: ubuntu-latest # ubuntu-latest 

2. create optfiles folder: workflow-fullstac-working-001\optfiles
3. create json file for environment in optfiles: **optfiles\sbx.json** (in this example, the environment is sbx, must match path specified in the workflow)

4. update:
    * branch name
    * azure remote state information
    * deployments: define the path where you terraform files are
    * notes: **make sure there is a tfvars folder and file as shown for the environment in each example folder**
```json

{
    "terraform_version": "1.9.2",
    "destroy_enabled": true,
    "uses_component_version_tag_value": false,
    "remote_state": {
      "azure": {
        "plan_container_name": "tfplan",
        "resource_group_name": "terraform",
        "state_container_name": "tfstate",
        "storage_account_name": "",
        "storage_account_location": "",
        "subscription_id": ""
      }
    },
    "deployments": [
      {
        "name": "01-default",
        "path": "examples/01-default",
        "remote_state_key": "01-default.tfstate",
        "runner": "ubuntu-latest",
        "run_plan_only": false
      },
      {
        "name": "04-vault-backup-policies",
        "path": "examples/04-vault-backup-policies",
        "remote_state_key": "04-vault-backup-policies.tfstate",
        "runner": "ubuntu-latest",
        "run_plan_only": false
      },
      {
        "name": "03-private-endpoints",
        "path": "examples/03-private-endpoints",
        "remote_state_key": "03-private-endpoints.tfstate",
        "runner": "ubuntu-latest",
        "run_plan_only": false
      }
    ]
  }

```