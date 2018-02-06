provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

module "network" {
  source              = "./network"
  tags                = "${var.tags}"
  bastion_vpc_cidr    = "${var.bastion_vpc_cidr}"
  bastion_subnet_cidr = "${var.bastion_subnet_cidr}"
  proxy_subnet_cidr   = "${var.proxy_subnet_cidr}"
  test_vpc_cidr       = "${var.test_vpc_cidr}"
  test_subnet_cidr    = "${var.test_subnet_cidr}"
}

module "bastion" {
  source              = "./bastion"
  tags                = "${var.tags}"
  aws_region          = "${var.aws_region}"
  vpc_id              = "${module.network.bastion_vpc_id}"
  subnet_id           = "${module.network.bastion_subnet_id}"
  bastion_ssh_inbound = "${var.bastion_inbound}"
  bastion_key         = "${var.bastion_key}"
  test_key            = "${var.test_key}"
  proxy_key           = "${var.proxy_key}"
}

module "proxy" {
  source              = "./proxy"
  tags                = "${var.tags}"
  vpc_id              = "${module.network.bastion_vpc_id}"
  subnet_id           = "${module.network.proxy_subnet_id}"
  ssh_inbound         = ["${var.bastion_subnet_cidr}"]
  bastion_rt_id       = "${module.network.bastion_rt_id}"
  bastion_subnet_cidr = "${var.bastion_subnet_cidr}"
  test_vpc_cidr       = "${var.test_vpc_cidr}"
  test_subnet_cidr    = "${var.test_subnet_cidr}"
  proxy_subnet_cidr   = "${var.proxy_subnet_cidr}"
  proxy_key           = "${var.proxy_key}"
}

module "securevpc" {
  source            = "./securevpc"
  tags              = "${var.tags}"
  vpc_id            = "${module.network.test_vpc_id}"
  subnet_id         = "${module.network.test_subnet_id}"
  ssh_inbound       = ["${var.bastion_subnet_cidr}"]
  bastion_vpc_id    = "${module.network.bastion_vpc_id}"
  bastion_subnet_id = "${module.network.bastion_subnet_id}"
  bastion_rt_id     = "${module.network.bastion_rt_id}"
  test_vpc_cidr     = "${var.test_vpc_cidr}"
  test_subnet_cidr  = "${var.test_subnet_cidr}"
  proxy_subnet_cidr = "${var.proxy_subnet_cidr}"
  proxy_address     = "${module.proxy.proxy_private_dns}"
  test_key          = "${var.test_key}"
}
