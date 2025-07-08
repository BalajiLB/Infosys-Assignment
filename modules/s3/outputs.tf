# ---------------------------------------------------------------------------
# Output the name of the main Infra S3 Bucket
# ---------------------------------------------------------------------------
output "infra_bucket_name" {
  value       = aws_s3_bucket.infra_bucket.id
  description = "The name (ID) of the created Infra S3 bucket"
}

# ---------------------------------------------------------------------------
# Output the name of the Replication Target S3 Bucket
# ---------------------------------------------------------------------------
output "replication_target_bucket_name" {
  value       = aws_s3_bucket.replication_target_bucket.id
  description = "The name (ID) of the S3 bucket used as the replication target"
}

# ---------------------------------------------------------------------------
# Output the name of the Logging Target S3 Bucket
# ---------------------------------------------------------------------------
output "logging_target_bucket_name" {
  value       = aws_s3_bucket.logging_target_bucket.id
  description = "The name (ID) of the S3 bucket where logs are delivered"
}

# ---------------------------------------------------------------------------
# Output the KMS Key ARN used for bucket encryption
# ---------------------------------------------------------------------------
output "kms_key_arn" {
  value       = aws_kms_key.s3_kms.arn
  description = "The ARN of the KMS key used to encrypt the S3 buckets"
}

# ---------------------------------------------------------------------------
# Output the ARN of the replication role
# ---------------------------------------------------------------------------
output "replication_role_arn" {
  value       = aws_iam_role.replication_role.arn
  description = "The ARN of the IAM role used for S3 replication"
}
