# modules/vault-config/variables.tf

variable "admin_password" {
  description = "Password for the admin user"
  type        = string
  sensitive   = true
}
