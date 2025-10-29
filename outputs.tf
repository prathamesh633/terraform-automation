output "instance_id" {
  value = aws_instance.web.id
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "ssh_command" {
  value = "ssh -i <your-private-key> ec2-user@${aws_instance.web.public_ip}  # or ssh -i <your-private-key> user1@${aws_instance.web.public_ip}"
}
