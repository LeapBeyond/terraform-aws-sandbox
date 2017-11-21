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

output "nexus_connect_string" {
  value = "${module.nexus.connect_string}"
}

output "nexus_url" {
  value = "${module.nexus.url}"
}
