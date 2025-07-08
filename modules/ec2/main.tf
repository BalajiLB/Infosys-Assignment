# Get the latest Amazon Linux 2023 AMI (example filter, adjust as needed)
data "aws_ami" "aws_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Local block to define instance details for multiple subnets
locals {
  ec2_instances = {
    "a" = { subnet_id = var.public_subnet_a_id, az = "us-west-2a" }
    "b" = { subnet_id = var.public_subnet_b_id, az = "us-west-2b" }
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.env}-instance-profile"
  role = var.ec2_role_name
}

# EC2 instance creation using for_each
resource "aws_instance" "ec2" {
  for_each               = local.ec2_instances

  ami                    = data.aws_ami.aws_ami.id
  instance_type          = var.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = var.security_group_ids
  associate_public_ip_address = true

  # Correctly referencing the security group from the module

  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name 
  user_data              = file("${path.root}/../../scripts/userdata.sh")
  monitoring             = true
  ebs_optimized          = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted  = true
    kms_key_id = var.kms_key_arn
  }

  tags = {
    Name = "${var.env}-ec2-${each.key}"
    AZ   = each.value.az
  }
}
