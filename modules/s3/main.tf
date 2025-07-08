# ----------------------------
# Get AWS account details
# ----------------------------
data "aws_caller_identity" "current" {}

# ----------------------------
# Generate a random string for bucket uniqueness
# ----------------------------
resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

# ----------------------------
# Create KMS Key
# ----------------------------
resource "aws_kms_key" "s3_kms" {
  description         = "KMS key for ${var.env}-${var.bucket_name}"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowAccountRoot",
        Effect = "Allow",
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowS3Services",
        Effect = "Allow",
        Principal = { Service = "s3.amazonaws.com" },
        Action = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"],
        Resource = "*",
        Condition = {
          StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
        }
      },
      {
        Sid    = "AllowS3ReplicationRole",
        Effect = "Allow",
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/dev-s3-replication-role" },
        Action = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"],
        Resource = "*"
      }
    ]
  })
}

# ----------------------------
# Create Main, Replication, Logging Buckets
# ----------------------------

resource "aws_s3_bucket" "infra_bucket" {
  bucket = "${var.env}-${var.bucket_name}-${random_string.bucket_suffix.result}"
  tags   = merge(var.tags, { Name = "${var.env}-${var.bucket_name}-${random_string.bucket_suffix.result}" })
}

resource "aws_s3_bucket" "replication_target_bucket" {
  bucket = "${var.replication_target_bucket}-${random_string.bucket_suffix.result}"
  tags   = merge(var.tags, { Name = "${var.replication_target_bucket}-${random_string.bucket_suffix.result}" })
}

resource "aws_s3_bucket" "logging_target_bucket" {
  bucket = "${var.logging_target_bucket}-${random_string.bucket_suffix.result}"
  tags   = merge(var.tags, { Name = "${var.logging_target_bucket}-${random_string.bucket_suffix.result}" })
}

# ----------------------------
# Enable Bucket Features
# ----------------------------

# Versioning
resource "aws_s3_bucket_versioning" "infra_versioning" {
  bucket = aws_s3_bucket.infra_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_versioning" "replication_target_versioning" {
  bucket = aws_s3_bucket.replication_target_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_versioning" "logging_versioning" {
  bucket = aws_s3_bucket.logging_target_bucket.id
  versioning_configuration { status = "Enabled" }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "replication_encryption" {
  bucket = aws_s3_bucket.replication_target_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms.arn
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_encryption" {
  bucket = aws_s3_bucket.logging_target_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public access blocks
resource "aws_s3_bucket_public_access_block" "infra" {
  bucket                  = aws_s3_bucket.infra_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "replication" {
  bucket                  = aws_s3_bucket.replication_target_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logging_target_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "infra_lifecycle" {
  bucket = aws_s3_bucket.infra_bucket.id
  rule {
    id     = "expire-old-objects"
    status = "Enabled"
    expiration { days = 365 }
    abort_incomplete_multipart_upload { days_after_initiation = 7 }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "replication_lifecycle" {
  bucket = aws_s3_bucket.replication_target_bucket.id
  rule {
    id     = "expire-replicated-objects"
    status = "Enabled"
    expiration { days = 365 }
    abort_incomplete_multipart_upload { days_after_initiation = 7 }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logging_lifecycle" {
  bucket = aws_s3_bucket.logging_target_bucket.id
  rule {
    id     = "delete-logs-after-365-days"
    status = "Enabled"
    expiration { days = 365 }
    abort_incomplete_multipart_upload { days_after_initiation = 7 }
  }
}

# Logging from Infra bucket
resource "aws_s3_bucket_logging" "infra_logging" {
  bucket        = aws_s3_bucket.infra_bucket.id
  target_bucket = aws_s3_bucket.logging_target_bucket.id
  target_prefix = "${var.env}/logs/"
}

# ----------------------------
# Replication Setup
# ----------------------------

resource "aws_iam_role" "replication_role" {
  name = "${var.env}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "s3.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "replication_policy" {
  role = aws_iam_role.replication_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetReplicationConfiguration", "s3:ListBucket"],
        Resource = [aws_s3_bucket.infra_bucket.arn]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObjectVersion", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"],
        Resource = ["${aws_s3_bucket.infra_bucket.arn}/*"]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"],
        Resource = ["${aws_s3_bucket.replication_target_bucket.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "infra_replication" {
  bucket = aws_s3_bucket.infra_bucket.id
  role   = aws_iam_role.replication_role.arn

  depends_on = [
    aws_s3_bucket_versioning.replication_target_versioning,
    aws_s3_bucket_versioning.infra_versioning
  ]

  rule {
    status = "Enabled"

    delete_marker_replication { status = "Disabled" }

    destination {
      bucket                = aws_s3_bucket.replication_target_bucket.arn
      storage_class         = "STANDARD"
      encryption_configuration { replica_kms_key_id = aws_kms_key.s3_kms.arn }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects { status = "Enabled" }
    }

    filter { prefix = "" }
  }
}

# ----------------------------
# Enable Event Notifications (S3 -> SNS)
# ----------------------------

resource "aws_sns_topic" "dummy_topic" {
  name = "dummy-topic"
}

resource "aws_sns_topic_policy" "dummy_topic_policy" {
  arn = aws_sns_topic.dummy_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "s3.amazonaws.com" },
      Action    = "SNS:Publish",
      Resource  = aws_sns_topic.dummy_topic.arn,
      Condition = { ArnLike = { "aws:SourceArn" = aws_s3_bucket.infra_bucket.arn } }
    }]
  })
}

resource "aws_s3_bucket_notification" "infra_notification" {
  bucket = aws_s3_bucket.infra_bucket.id

  topic {
    topic_arn = aws_sns_topic.dummy_topic.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_sns_topic.dummy_topic,
    aws_sns_topic_policy.dummy_topic_policy
  ]
}

# ----------------------------
# Default Security Group Restriction
# ----------------------------
resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
  ingress = []
  egress  = []
}
