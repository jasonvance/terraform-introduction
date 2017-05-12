module "webserver" {
  source                  = "./../../../modules/webserver"
  private_subnets_ids         = "${module.network.private_subnet_ids}"

}
