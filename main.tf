terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
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
  source                = "./modules/ec2"
  bucket_name           = var.vault_bucket_name
  kms_key_id            = module.kms.kms_key_id
  instance_profile_name = module.iam.instance_profile_name
  sg_id                 = module.network.vault_sg_id
  subnet_id             = module.network.subnet_id
  aws_region            = var.aws_region
  instance_type         = var.instance_type
  vpn_ip_cidr           = var.vpn_ip_cidr
}

output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
}

output "kms_key_arn" {
  value = module.kms.kms_key_arn
}
