terraform {
  required_providers {
    aws = {
      version = ">= 3.2.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}
