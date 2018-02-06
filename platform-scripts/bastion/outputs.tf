output "bastion_public_dns" {
  value = "${aws_instance.bastion.public_dns}"
}

output "bastion_private_dns" {
  value = "${aws_instance.bastion.private_dns}"
}

output "connect_string" {
  value = "ssh -i ${var.bastion_key}.pem ${var.bastion_user}@${aws_instance.bastion.public_dns}"
}
