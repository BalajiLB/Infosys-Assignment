variable "env" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "ingress_descriptions" {
  type        = list(string)
  description = "Descriptions for each ingress rule"
}

variable "ingress_from_ports" {
  type        = list(number)
  description = "From ports for each ingress rule"
}

variable "ingress_to_ports" {
  type        = list(number)
  description = "To ports for each ingress rule"
}

variable "ingress_cidr_blocks" {
  type        = list(list(string))
  description = "CIDR blocks for each ingress rule (nested list)"
}

variable "egress_from_port" {
  type = number
}

variable "egress_to_port" {
  type = number
}

variable "egress_protocol" {
  type = string
}

variable "egress_cidr_blocks" {
  type = list(string)
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
}

variable "ingress_protocols" {
  type        = list(string)
  description = "Protocols for each ingress rule"
}