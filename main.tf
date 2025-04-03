# terraform/main.tf

terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

variable "enable_vault_config" {
  description = "Controla si se aplica la configuración de Vault"
  type        = bool
  default     = true
}

resource "random_password" "vault_token" {
  length  = 24
  special = false
}

resource "random_password" "vault_admin_password" {
  length  = 20
  special = true
}

module "kms" {
  source = "./modules/kms"
}

module "s3" {
  source         = "./modules/s3"
  bucket_name    = var.vault_bucket_name
  kms_key_arn    = module.kms.kms_key_arn
  depends_on_key = module.kms.kms_key_id
}

module "iam" {
  source = "./modules/iam"
}

module "network" {
  source      = "./modules/network"
  vpn_ip_cidr = var.vpn_ip_cidr
}

module "ec2" {
  source = "./modules/ec2"

  bucket_name           = var.vault_bucket_name
  kms_key_id            = module.kms.kms_key_id
  instance_profile_name = module.iam.instance_profile_name
  sg_id                 = module.network.vault_sg_id
  subnet_id             = module.network.subnet_id
  aws_region            = var.aws_region
  instance_type         = var.instance_type
  vpn_ip_cidr           = var.vpn_ip_cidr

  vault_root_token = random_password.vault_token.result
}

# Esperar a que Vault esté desellado antes de leer el token
resource "null_resource" "wait_for_vault_ready" {
  depends_on = [module.ec2]

  provisioner "local-exec" {
    command = <<EOT
      echo "⌛ Esperando a que Vault esté desellado..."
      until curl -sk https://${module.ec2.ec2_public_ip}:8200/v1/sys/health | jq '.sealed == false' | grep -q true; do
        sleep 5
      done
      echo "✅ Vault está desellado y listo."
    EOT
  }
}

# Token root leído después de que Vault esté listo
data "aws_secretsmanager_secret_version" "vault_root" {
  count     = var.enable_vault_config ? 1 : 0
  secret_id = "vault-root-token"
  depends_on = [null_resource.wait_for_vault_ready]
}

# Provider Vault (post-init) con alias y fallback
provider "vault" {
  alias           = "post_init"
  address         = "https://${module.ec2.ec2_public_ip}:8200"
  skip_tls_verify = true
  token           = try(data.aws_secretsmanager_secret_version.vault_root[0].secret_string, "")
}

# Módulo que aplica la configuración de Vault
module "vault_config" {
  source         = "./modules/vault-config"
  admin_password = random_password.vault_admin_password.result
  providers = {
    vault = vault.post_init
  }

  depends_on = [null_resource.wait_for_vault_ready]
}

# Outputs
output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
}

output "kms_key_arn" {
  value = module.kms.kms_key_arn
}

output "vault_token" {
  value     = random_password.vault_token.result
  sensitive = true
}

output "vault_admin_password" {
  value     = random_password.vault_admin_password.result
  sensitive = true
}
