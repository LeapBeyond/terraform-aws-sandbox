output "bastion_profile_name" {
  value = "${aws_iam_instance_profile.bastion_profile.name}"
}

output "ssmtest_profile_name" {
  value = "${aws_iam_instance_profile.test_ssm_profile.name}"
}

output "bastion_ssh_access_sg_id" {
  value = "${aws_security_group.bastion_ssh_access.id}"
}

output "ssmtest_ssh_access_sg_id" {
  value = "${aws_security_group.ssmtest_ssh_access.id}"
}

output "ssh_from_bastion_sg_id" {
  value = "${aws_security_group.proxy_ssh.id}"
}

output "proxy_sg_id" {
  value = "${aws_security_group.proxy.id}"
}

output "ssmtest_proxy_access_sg_id" {
  value = "${aws_security_group.ssmtest_proxy_access.id}"
}
