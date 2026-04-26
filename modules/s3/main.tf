resource "aws_s3_bucket" "bucket" {

  bucket = var.bucket_name
  force_destroy  = true 
  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-app-bucket" 
    },
    var.tags
  )

}

resource "aws_s3_bucket_public_access_block" "bucket" {

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_versioning" "bucket" {

  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.versioning_enabled 
  }

}


resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    id     = "cleanup-old-files"
    status = "Enabled"
    expiration {
      days = var.lifecycle_days
    }
  }
}