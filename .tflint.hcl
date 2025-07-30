# .tflint.hcl
# TFLint configuration for Terraform code quality

# Plugin configuration
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# AWS provider plugin (if needed in future)
# plugin "aws" {
#   enabled = true
#   version = "0.30.0"
#   source  = "github.com/terraform-linters/tflint-ruleset-aws"
# }

# Terraform language rules
rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_module_version" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true

  # Custom naming formats
  format = "snake_case"

  # Resource naming
  resource {
    format = "snake_case"
  }

  # Data source naming
  data {
    format = "snake_case"
  }

  # Variable naming
  variable {
    format = "snake_case"
  }

  # Output naming
  output {
    format = "snake_case"
  }

  # Local value naming
  locals {
    format = "snake_case"
  }

  # Module naming
  module {
    format = "snake_case"
  }
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = true
}

# Incus provider specific rules (custom)
rule "incus_instance_naming" {
  enabled = true
}

rule "incus_network_naming" {
  enabled = true
}

# Performance rules
rule "terraform_typed_variables" {
  enabled = true
}

# Security rules
rule "terraform_sensitive_variable_no_default" {
  enabled = true
}

# Ignore patterns
config {
  # Ignore external modules
  ignore_module = {
    "terraform-aws-modules/*" = true
  }

  # Disabled checks for generated files
  disabled_by_default = false

  # Variable validation
  varfile = ["terraform.tfvars", "*.auto.tfvars"]
}
