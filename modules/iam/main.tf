resource "aws_iam_role" "vault_instance_role" {
  name = "vault-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vault_permissions" {
  role       = aws_iam_role.vault_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "vault_instance_profile" {
  name = "vault-instance-profile"
  role = aws_iam_role.vault_instance_role.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.vault_instance_profile.name
}
