# modules/ec2/main.tf

variable "bucket_name" {}
variable "kms_key_id" {}
variable "instance_profile_name" {}
variable "sg_id" {}
variable "subnet_id" {}
variable "aws_region" {}
variable "instance_type" {}
variable "vpn_ip_cidr" {}

# 👇 NUEVA VARIABLE PARA EL TOKEN
variable "vault_root_token" {
  description = "Root token to use when initializing Vault"
  type        = string
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "vault" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_id]
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = true

  # ✅ TEMPLATE CON VARIABLES INYECTADAS
  user_data = templatefile("${path.module}/install_vault.sh.tmpl", {
  bucket_name        = var.bucket_name,
  kms_key_id         = var.kms_key_id,
  aws_region         = var.aws_region,
  vault_version      = "1.15.5",
  vault_root_token   = var.vault_root_token
})

  tags = {
    Name = "vault-server"
  }
}

output "ec2_public_ip" {
  value = aws_instance.vault.public_ip
}
