variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

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
  description = "Availability Zone for public subnet A"
  type        = string
}

variable "availability_zone_b" {
  description = "Availability Zone for public subnet B"
  type        = string
}

variable "default_route_cidr" {
  description = "CIDR block for the default route (usually 0.0.0.0/0)"
  type        = string
}

variable "aws_region" {
  description   = "region"
  type          = string
}

variable "flow_logs_role_arn" {
  type = string
}


