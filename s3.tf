# S3 버킷 생성
resource "aws_s3_bucket" "main" {
  bucket = local.s3_bucket_name
  force_destroy = true

  tags = {
    Name = "${var.project_name}-bucket"
  }
}

# S3 버킷 접근 제어 설정
resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 버킷 ACL 설정
resource "aws_s3_bucket_acl" "main" {
  depends_on = [aws_s3_bucket_ownership_controls.main]
  
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

# S3 버킷 버전 관리 설정
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 버킷 라이프사이클 규칙 설정
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "images-lifecycle"
    status = "Enabled"
    
    filter {
      prefix = "images/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 180
    }
  }
}

# S3 버킷 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 버킷 이름 생성 로직
locals {
  s3_bucket_name = var.s3_bucket_name != null ? var.s3_bucket_name : "${var.project_name}-${random_id.bucket_suffix.hex}"
}

# 랜덤 ID 생성 (S3 버킷 이름 중복 방지용)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}