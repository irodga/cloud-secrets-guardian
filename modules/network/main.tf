# 📄 modules/network/main.tf

variable "vpn_ip_cidr" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_security_group" "vault_sg" {
  name        = "vault-sg"
  description = "Allow Vault access only from VPN IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = [var.vpn_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vault_sg_id" {
  value = aws_security_group.vault_sg.id
}

output "subnet_id" {
  value = data.aws_subnets.default.ids[0]
}
