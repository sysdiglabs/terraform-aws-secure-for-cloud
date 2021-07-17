variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "aws_organization_sysdig_account" {
  type = object({
    # true/false values whether a new account shold be created (testing purpose) or use an existing one
    create = bool

    # (create=false) the account_id **within the organization** to be used
    param_use_account_id = optional(string)

    # (create=true) the email associated with the to be created account.
    # The email address of the owner to assign to the new member account.
    # This email address must not already be associated with another AWS account
    param_creation_email = optional(string)
  })
  default = {
    create = true
  }
}
