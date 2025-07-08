# --------------------------------------------------------------------
# AWS Provider
# --------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}

# --------------------------------------------------------------------
# IAM Role for VPC Flow Logs
# --------------------------------------------------------------------
data "aws_iam_policy_document" "flow_logs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"] # VPC Flow Logs service
    }
  }
}

resource "aws_iam_role" "flow_logs_role" {
  name               = "${var.env}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role_policy.json
}

# --------------------------------------------------------------------
# IAM Role for EC2 Instances
# --------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"] # EC2 service
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.env}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

# --------------------------------------------------------------------
# KMS Key for S3 and EC2 encryption
# --------------------------------------------------------------------
resource "aws_kms_key" "s3_kms" {
  description         = "KMS key for S3 bucket and EC2 volume encryption"
  enable_key_rotation = true
}

# --------------------------------------------------------------------
# VPC Module: Creates VPC with 2 public subnets and Flow Logs
# --------------------------------------------------------------------
module "vpc" {
  source               = "../../modules/vpc"
  env                  = var.env
  vpc_cidr             = var.vpc_cidr
  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_b_cidr = var.public_subnet_b_cidr
  availability_zone_a  = var.availability_zone_a
  availability_zone_b  = var.availability_zone_b
  default_route_cidr   = var.default_route_cidr
  aws_region           = var.aws_region
  flow_logs_role_arn   = aws_iam_role.flow_logs_role.arn # Attach VPC Flow Logs IAM Role
}

# --------------------------------------------------------------------
# Security Group Module: Configures SG with dynamic ingress/egress
# --------------------------------------------------------------------
module "sg" {
  source = "../../modules/sg"
  env    = var.env
  vpc_id = module.vpc.vpc_id

  # Ingress variables
  ingress_descriptions = var.ingress_descriptions
  ingress_from_ports   = var.ingress_from_ports
  ingress_to_ports     = var.ingress_to_ports
  ingress_cidr_blocks  = var.ingress_cidr_blocks
  ingress_protocols    = var.ingress_protocols

  # Egress variables
  egress_from_port   = var.egress_from_port
  egress_to_port     = var.egress_to_port
  egress_protocol    = var.egress_protocol
  egress_cidr_blocks = var.egress_cidr_blocks

  # Common tags
  tags = var.tags
}

# --------------------------------------------------------------------
# EC2 Module: Deploys EC2 instances in public subnets with SG and KMS encryption
# --------------------------------------------------------------------
module "ec2" {
  source             = "../../modules/ec2"
  env                = var.env
  instance_type      = var.instance_type
  public_subnet_a_id = module.vpc.public_subnet_a_id
  public_subnet_b_id = module.vpc.public_subnet_b_id
  security_group_ids = [module.sg.ec2_sg_id]
  ec2_role_name      = aws_iam_role.ec2_role.name
  kms_key_arn        = aws_kms_key.s3_kms.arn
}

# --------------------------------------------------------------------
# S3 Module: Creates buckets with encryption, replication, and logging
# --------------------------------------------------------------------
module "s3" {
  source                    = "../../modules/s3"
  env                       = var.env
  bucket_name               = var.bucket_name
  replication_target_bucket = var.replication_target_bucket
  logging_target_bucket     = var.logging_target_bucket
  tags                      = var.tags
  vpc_id                    = module.vpc.vpc_id
  aws_region                = var.aws_region
}
