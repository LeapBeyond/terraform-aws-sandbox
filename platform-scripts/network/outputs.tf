output "bastion_vpc_id" {
  value = "${aws_vpc.bastion_vpc.id}"
}

output "proxy_subnet_id" {
  value = "${aws_subnet.proxy_subnet.id}"
}

output "bastion_subnet_id" {
  value = "${aws_subnet.bastion_subnet.id}"
}

output "bastion_rt_id" {
  value = "${aws_route_table.bastion_rt.id}"
}

output "test_vpc_id" {
  value = "${aws_vpc.test_vpc.id}"
}

output "test_subnet_id" {
  value = "${aws_subnet.test_subnet.id}"
}
