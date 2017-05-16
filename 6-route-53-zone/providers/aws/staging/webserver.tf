module "webserver" {
  source                  = "./../../../modules/webserver"
  private_subnets_ids     = "${module.network.private_subnet_ids}"
  environment             = "${var.environment}"
  r53_zone_id             = "${var.r53_zone_id}"
  region                  = "${var.region}"
  service                 = "${var.service}"
}
