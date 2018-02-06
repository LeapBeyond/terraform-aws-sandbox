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
  source = "./security"
  tags   = "${var.tags}"
}

module "bastion" {
  source       = "./bastion"
  tags         = "${var.tags}"
  vpc_id       = "${module.network.bastion_vpc_id}"
  subnet_id    = "${module.network.bastion_subnet_id}"
  ssh_inbound  = ["${module.network.bastion_inbound}"]
  profile_name = "${module.security.bastion_profile_name}"
  aws_region   = "${var.aws_region}"
  bastion_key  = "${var.bastion_key}"
  test_key     = "${var.test_key}"
  proxy_key    = "${var.proxy_key}"
}

module "proxy" {
  source              = "./proxy"
  tags                = "${var.tags}"
  vpc_id              = "${module.network.bastion_vpc_id}"
  subnet_id           = "${module.network.proxy_subnet_id}"
  ssh_inbound         = ["${module.network.bastion_subnet_cidr}"]
  bastion_subnet_cidr = "${module.network.bastion_subnet_cidr}"
  test_vpc_cidr       = "${module.network.test_vpc_cidr}"
  test_subnet_cidr    = "${module.network.test_subnet_cidr}"
  proxy_key           = "${var.proxy_key}"
}

module "securevpc" {
  source            = "./securevpc"
  tags              = "${var.tags}"
  vpc_id            = "${module.network.test_vpc_id}"
  subnet_id         = "${module.network.test_subnet_id}"
  ssh_inbound       = ["${module.network.bastion_subnet_cidr}"]
  profile_name      = "${module.security.ssmtest_profile_name}"
  proxy_subnet_cidr = "${module.network.proxy_subnet_cidr}"
  proxy_address     = "${module.proxy.proxy_private_dns}"
  test_key          = "${var.test_key}"
}
