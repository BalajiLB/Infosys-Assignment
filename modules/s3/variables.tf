# Environment name (e.g., dev, prod, staging)
variable "env" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

# The base name of the main S3 bucket (random suffix and env will be added automatically)
variable "bucket_name" {
  type        = string
  description = "Name of the main S3 bucket (without environment prefix)"
}

# Name of the destination bucket for cross-region replication (random suffix will be added)
variable "replication_target_bucket" {
  type        = string
  description = "The name of the destination bucket for cross-region replication"
}

# Name of the bucket that stores access logs (random suffix will be added)
variable "logging_target_bucket" {
  type        = string
  description = "The S3 bucket where access logs will be delivered"
}

# Common tags applied to all resources
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources"
}

# VPC ID used to configure the default security group
variable "vpc_id" {
  description = "VPC ID for default security group"
  type        = string
}

# AWS region where the resources will be created
variable "aws_region" {
  description = "AWS Region"
  type        = string
}
