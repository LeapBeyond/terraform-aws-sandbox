output "bastion_profile_name" {
  value = "${aws_iam_instance_profile.bastion_profile.name}"
}

output "ssmtest_profile_name" {
  value = "${aws_iam_instance_profile.test_ssm_profile.name}"
}
