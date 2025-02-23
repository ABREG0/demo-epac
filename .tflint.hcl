# https://github.com/terraform-linters/tflint-ruleset-azurerm/blob/master/docs/rules/azurerm_resource_missing_tags.md

plugin "azurerm" {
    enabled = true
    version = "0.27.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

plugin "terraform" {
  enabled = true
  version = "0.10.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

# General Terraform rules
rule "terraform_deprecated_interpolation" {
  enabled = true
}
 
# Disallow variables, data sources, and locals that are declared but never used.
rule "terraform_unused_declarations" {
enabled = true
}
 
# Disallow // comments in favor of #.
rule "terraform_comment_syntax" {
enabled = true
}
 
# Disallow output declarations without description.
rule "terraform_documented_outputs" {
enabled = false
}
 
# Disallow variable declarations without description.
rule "terraform_documented_variables" {
enabled = true
}
 
# Disallow variable declarations without type.
rule "terraform_typed_variables" {
enabled = true
}
rule "azurerm_resource_missing_tags" {
  enabled = true
  tags = ["env", "owner", "dept"]
  exclude = [] # (Optional) Exclude some resource types from tag checks
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}
rule "terraform_deprecated_interpolation" {
  enabled = false
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = false
}

rule "terraform_deprecated_lookup" {
  enabled = false
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = false
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_empty_list_equality" {
  enabled = false
}

rule "terraform_standard_module_structure" {
  enabled = false
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = true
}

rule "terraform_heredoc_usage" {
  enabled = false
}

rule "terraform_module_provider_declaration" {
  enabled = true
}

rule "terraform_output_separate" {
  enabled = true
}

rule "terraform_required_providers_declaration" {
  enabled = true
}

rule "terraform_required_version_declaration" {
  enabled = true
}
