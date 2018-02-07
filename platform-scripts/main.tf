provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

module "network" {
  source = "./network"
  tags   = "${var.tags}"
}

module "code" {
  source = "./code"
  tags   = "${var.tags}"
}

module "security" {
  source              = "./security"
  tags                = "${var.tags}"
  ssh_inbound         = ["${var.ssh_inbound}"]
  bastion_subnet_cidr = "${module.network.bastion_subnet_cidr}"
  proxy_subnet_cidr   = "${module.network.proxy_subnet_cidr}"
  bastion_vpc_id      = "${module.network.bastion_vpc_id}"
  ssmtest_vpc_id      = "${module.network.test_vpc_id}"
}

module "bastion" {
  source           = "./instances/bastion"
  tags             = "${var.tags}"
  subnet_id        = "${module.network.bastion_subnet_id}"
  profile_name     = "${module.security.bastion_profile_name}"
  ssh_access_sg_id = "${module.security.bastion_ssh_access_sg_id}"
  aws_region       = "${var.aws_region}"
  bastion_key      = "${var.bastion_key}"
  test_key         = "${var.test_key}"
  proxy_key        = "${var.proxy_key}"
}

module "proxy" {
  source              = "./instances/proxy"
  tags                = "${var.tags}"
  subnet_id           = "${module.network.proxy_subnet_id}"
  ssh_sg_id           = "${module.security.ssh_from_bastion_sg_id}"
  proxy_sg_id         = "${module.security.proxy_sg_id}"
  bastion_subnet_cidr = "${module.network.bastion_subnet_cidr}"
  test_subnet_cidr    = "${module.network.test_subnet_cidr}"
  proxy_key           = "${var.proxy_key}"
}

module "ssmtest" {
  source             = "./instances/ssmtest"
  tags               = "${var.tags}"
  subnet_id          = "${module.network.test_subnet_id}"
  ssh_sg_id          = "${module.security.ssh_from_bastion_sg_id}"
  proxy_access_sg_id = "${module.security.ssmtest_proxy_access_sg_id}"
  profile_name       = "${module.security.ssmtest_profile_name}"
  proxy_address      = "${module.proxy.proxy_private_dns}"
  test_key           = "${var.test_key}"
}
