# modules/vault-config/main.tf

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("${path.module}/policies/admin-policy.hcl")
}

resource "vault_generic_endpoint" "admin_user" {
  depends_on = [
    vault_auth_backend.userpass,
    vault_policy.admin
  ]

  path = "auth/userpass/users/admin"

  data_json = jsonencode({
    password = var.admin_password
    policies = ["admin"]
  })
}
