output "bastion_public_dns" {
  value = "${aws_instance.bastion.public_dns}"
}

output "bastion_private_dns" {
  value = "${aws_instance.bastion.private_dns}"
}

output "connect_string" {
  value = "ssh -i ${var.bastion_key}.pem ${var.bastion_user}@${aws_instance.bastion.public_dns}"
}

output "bastion_subnet_cidr" {
  value = "${var.bastion_subnet_cidr}"
}

output "bastion_vpc_id" {
  value = "${aws_vpc.bastion_vpc.id}"
}

output "bastion_subnet_id" {
  value = "${aws_subnet.bastion_subnet.id}"
}

output "bastion_ssh_sg_id" {
  value = "${aws_security_group.bastion_ssh.id}"
}
