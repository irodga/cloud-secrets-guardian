variable "bucket_name" {}
variable "kms_key_arn" {}
variable "depends_on_key" {}

resource "aws_s3_bucket" "vault" {
  bucket        = var.bucket_name
  force_destroy = false
  depends_on    = [var.depends_on_key]
}

resource "aws_s3_bucket_versioning" "vault" {
  bucket = aws_s3_bucket.vault.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vault" {
  bucket = aws_s3_bucket.vault.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}
