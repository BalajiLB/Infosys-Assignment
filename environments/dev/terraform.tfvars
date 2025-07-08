# General
env        = "dev"
aws_region = "us-west-2"

# VPC
vpc_cidr             = "10.0.0.0/16"
public_subnet_a_cidr = "10.0.1.0/24"
public_subnet_b_cidr = "10.0.2.0/24"
default_route_cidr   = "0.0.0.0/0"
availability_zone_a  = "us-west-2a"
availability_zone_b  = "us-west-2b"

# EC2
instance_type = "t2.micro"
ec2_role_name = "dev-ec2-role"

# S3
bucket_name               = "dev-infra-bucket"
logging_target_bucket     = "my-logging-bucket"
replication_target_bucket = "my-replication-bucket"

# Security Group - Ingress
ingress_descriptions = ["Allow HTTP"]
ingress_from_ports   = [80]
ingress_to_ports     = [80]
ingress_protocols    = ["tcp"]
ingress_cidr_blocks = [
  ["0.0.0.0/0"],
]

# Security Group - Egress
egress_from_port   = 0
egress_to_port     = 0
egress_protocol    = "-1"
egress_cidr_blocks = ["0.0.0.0/0"]

# Common Tags
tags = {
  Environment = "dev"
  Owner       = "team-dev"
}

