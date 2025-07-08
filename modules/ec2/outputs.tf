output "instance_ids" {
  value = { for k, instance in aws_instance.ec2 : k => instance.id }
}

output "public_ips" {
  value = { for k, instance in aws_instance.ec2 : k => instance.public_ip }
}
