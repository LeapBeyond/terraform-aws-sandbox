provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

module "bastion" {
  source              = "./bastion"
  tags                = "${var.tags}"
  bastion_key         = "${var.bastion_key}"
  test_key            = "${var.test_key}"
  aws_region          = "${var.aws_region}"
  bastion_ssh_inbound = "${var.bastion_inbound}"
}

module "securevpc" {
  source            = "./securevpc"
  tags              = "${var.tags}"
  ssh_inbound       = ["${module.bastion.bastion_subnet_cidr}"]
  bastion_vpc_id    = "${module.bastion.bastion_vpc_id}"
  bastion_subnet_id = "${module.bastion.bastion_subnet_id}"
  bastion_rt_id     = "${module.bastion.bastion_rt_id}"

  # nexus_subnet_id   = "${module.nexus.nexus_subnet_id}"
  test_key = "${var.test_key}"
}

#
# module "nexus" {
#   source            = "./nexus"
#   tags              = "${var.tags}"
#   bastion_ssh_sg_id = "${module.bastion.bastion_ssh_sg_id}"
#   bastion_subnet_id = "${module.bastion.bastion_subnet_id}"
#   bastion_inbound   = "${var.bastion_inbound}"
#   bastion_rt_id     = "${module.bastion.bastion_rt_id}"
#   bastion_vpc_id    = "${module.bastion.bastion_vpc_id}"
#   nexus_key         = "${var.bastion_key}"
#   test_vpc_cidr     = "${module.securevpc.test_vpc_cidr}"
# }

