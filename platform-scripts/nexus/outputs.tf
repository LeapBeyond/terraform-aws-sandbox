output "nexus_public_dns" {
  value = "${aws_spot_instance_request.nexus.public_dns}"
}

output "nexus_private_dns" {
  value = "${aws_spot_instance_request.nexus.private_dns}"
}

output "connect_string" {
  value = "ssh -i ${var.nexus_key}.pem ${var.nexus_user}@${aws_spot_instance_request.nexus.public_dns}"
}

output "url" {
  value = "http://${aws_spot_instance_request.nexus.public_dns}:8081"
}

output "nexus_subnet_id" {
  value = "${aws_subnet.nexus_subnet.id}"
}
