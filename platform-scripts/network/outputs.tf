output "bastion_vpc_id" {
  value = "${aws_vpc.bastion_vpc.id}"
}

output "bastion_subnet_cidr" {
  value = "${aws_subnet.bastion_subnet.cidr_block}"
}

output "bastion_subnet_id" {
  value = "${aws_subnet.bastion_subnet.id}"
}

output "bastion_rt_id" {
  value = "${aws_route_table.bastion_rt.id}"
}

output "proxy_subnet_id" {
  value = "${aws_subnet.proxy_subnet.id}"
}

output "proxy_subnet_cidr" {
  value = "${aws_subnet.bastion_subnet.cidr_block}"
}

output "test_vpc_id" {
  value = "${aws_vpc.test_vpc.id}"
}

output "test_subnet_id" {
  value = "${aws_subnet.test_subnet.id}"
}

output "test_subnet_cidr" {
  value = "${aws_subnet.test_subnet.cidr_block}"
}

output "test_vpc_cidr" {
  value = "${aws_vpc.test_vpc.cidr_block}"
}
