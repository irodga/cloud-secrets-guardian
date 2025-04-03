# terraform/variables.tf

variable "aws_region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "vault_bucket_name" {
  default     = "vault-prod-backend-ivan"
  description = "Name of the S3 bucket for Vault backend"
}

variable "vpn_ip_cidr" {
  default     = "189.153.61.106/32"
  description = "VPN CIDR range"
}

variable "instance_type" {
  default     = "t3.micro"
  description = "EC2 instance type"
}
