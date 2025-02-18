output "instance_id" {
  description = "ID of the Salt Master instance"
  value       = aws_instance.master.id
}

output "public_ip" {
  description = "Public IP address of the Salt Master"
  value       = aws_instance.master.public_ip
}

output "private_ip" {
  description = "Private IP address of the Salt Master"
  value       = aws_instance.master.private_ip
}
