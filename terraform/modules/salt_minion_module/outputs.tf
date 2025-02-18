output "instance_id" {
  description = "ID of the created instance"
  value       = aws_instance.vm.id
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.vm.private_ip
}
