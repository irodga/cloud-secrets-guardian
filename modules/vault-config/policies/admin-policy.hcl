# modules/vault-config/policies/admin-policy.hcl

path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
