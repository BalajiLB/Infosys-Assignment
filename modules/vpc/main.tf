data "aws_caller_identity" "current" {}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-vpc"
  }
}

# Public Subnet A
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_a_cidr
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.env}-public-subnet-a"
  }
}

# Public Subnet B
resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_b_cidr
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.env}-public-subnet-b"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.default_route_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.env}-public-route-table"
  }
}

# Route Table Association for Subnet A
resource "aws_route_table_association" "public_route_table_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

# Route Table Association for Subnet B
resource "aws_route_table_association" "public_route_table_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_flow_log" "vpc_flow" {
  log_destination      = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/vpc-flow-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = var.flow_logs_role_arn
}

# Restrict Default Security Group (CKV2_AWS_12)

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress = [] # Remove all inbound rules
  egress  = [] # Remove all outbound rules
}
