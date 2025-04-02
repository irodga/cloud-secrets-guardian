resource "aws_kms_key" "vault" {
  description             = "Vault Auto-Unseal Key"
  deletion_window_in_days = 10
  enable_key_rotation    = true
}

output "kms_key_arn" {
  value = aws_kms_key.vault.arn
}

output "kms_key_id" {
  value = aws_kms_key.vault.key_id
}
