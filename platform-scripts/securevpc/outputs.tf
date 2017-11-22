output "ssmtest_private_dns" {
  value = "${aws_instance.ssmtest.private_dns}"
}

output "test_vpc_cidr" {
  value = "${var.test_vpc_cidr}"
}
