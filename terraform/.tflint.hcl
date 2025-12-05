plugin "terraform" {
  enabled = true
  preset  = "all"  # Enable all rules, then customize below
}

plugin "aws" {
  enabled = true
  version = "0.31.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Note: terraform_naming_convention produces "notice" level, not visible by default
# Use: tflint --enable-rule=terraform_naming_convention to see these issues
# Or add to command: --minimum-failure-severity=notice

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
  style   = "semver"
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}
