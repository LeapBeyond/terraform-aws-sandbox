output "proxy_public_dns" {
  value = "${aws_instance.proxy.public_dns}"
}

output "proxy_private_dns" {
  value = "${aws_instance.proxy.private_dns}"
}
