module "network" {
  source                  = "./../../../modules/network/public_private"

  vpc_cidr                = "${var.vpc_cidr}"
  azs                     = "${var.azs}"
  region                  = "${var.region}"
  private_subnets         = "${var.private_subnets}"
  public_subnets          = "${var.public_subnets}"
  key_name                = "${aws_key_pair.site_key.key_name}"
  sub_domain              = "${var.sub_domain}"
  vpn_ip                  = "${var.vpn_ip}"
  bastion_instance_type   = "${var.bastion_instance_type}"
  bastion_nat_ami         = "${var.bastion_nat_ami}"
  environment             = "${var.environment}"
}
