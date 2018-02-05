output "project_tags" {
  value = "${var.tags}"
}

output "aws_region" {
  value = "${var.aws_region}"
}

output "bastion_connect_string" {
  value = "${module.bastion.connect_string}"
}

output "ssmtest_private_dns" {
  value = "${module.securevpc.ssmtest_private_dns}"
}

output "proxy_public_dns" {
  value = "${module.proxy.proxy_public_dns}"
}

output "proxy_private_dns" {
  value = "${module.proxy.proxy_private_dns}"
}
