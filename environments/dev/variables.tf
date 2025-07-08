# Environment and Region
variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet B"
  type        = string
}

variable "availability_zone_a" {
  description = "Availability zone for public subnet A"
  type        = string
}

variable "availability_zone_b" {
  description = "Availability zone for public subnet B"
  type        = string
}

variable "default_route_cidr" {
  description = "Default route CIDR (usually 0.0.0.0/0)"
  type        = string
}

# EC2 Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ec2_role_name" {
  description = "IAM Role name to attach to EC2 instance profile"
  type        = string
}

# S3 Variables
variable "bucket_name" {
  description = "Name of the main S3 bucket (without environment prefix)"
  type        = string
}

variable "replication_target_bucket" {
  description = "The name of the destination bucket for cross-region replication"
  type        = string
}

variable "logging_target_bucket" {
  description = "The S3 bucket where access logs will be delivered"
  type        = string
}

# Security Group - Split Ingress Variables
variable "ingress_descriptions" {
  description = "Descriptions for each ingress rule"
  type        = list(string)
}

variable "ingress_from_ports" {
  description = "From ports for each ingress rule"
  type        = list(number)
}

variable "ingress_to_ports" {
  description = "To ports for each ingress rule"
  type        = list(number)
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks for each ingress rule"
  type        = list(list(string))
}

# Security Group - Egress Variables
variable "egress_from_port" {
  description = "Egress from port"
  type        = number
}

variable "egress_to_port" {
  description = "Egress to port"
  type        = number
}

variable "egress_protocol" {
  description = "Egress protocol"
  type        = string
}

variable "egress_cidr_blocks" {
  description = "Egress CIDR blocks"
  type        = list(string)
}

# Common Tags
variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "ingress_protocols" {
  type        = list(string)
  description = "Protocols for each ingress rule"
}

