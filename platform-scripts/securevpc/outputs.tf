output "ssmtest_private_dns" {
  value = "${aws_instance.ssmtest.private_dns}"
}
