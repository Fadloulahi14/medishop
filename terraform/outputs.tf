output "front_public_ip" {
  value = var.associate_front_eip ? aws_eip.front[0].public_ip : aws_instance.front.public_ip
}

output "back_private_ip" {
  value = aws_instance.back.private_ip
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
