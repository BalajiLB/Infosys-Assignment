locals {
  ingress_rules = [
    for idx in range(length(var.ingress_descriptions)) : {
      description = var.ingress_descriptions[idx]
      from_port   = var.ingress_from_ports[idx]
      to_port     = var.ingress_to_ports[idx]
      protocol    = var.ingress_protocols[idx]
      cidr_blocks = var.ingress_cidr_blocks[idx]
    }
  ]
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.env}-ec2-sg"
  description = "Allow inbound traffic to EC2 instances"
  vpc_id      = var.vpc_id

  # Ingress Rules
  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Egress Rule (Allow all outbound)
  egress {
    description = "Allow all outbound traffic"
    from_port   = var.egress_from_port
    to_port     = var.egress_to_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }

  # Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.env}-sg"
    }
  )
}
