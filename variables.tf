variable "aws_region" {
  default = "us-east-2"
}

variable "vault_bucket_name" {
  default = "vault-prod-backend-ivan"
}

variable "vpn_ip_cidr" {
  default = "189.153.61.106/32"
}

variable "instance_type" {
  default = "t3.micro"
}
