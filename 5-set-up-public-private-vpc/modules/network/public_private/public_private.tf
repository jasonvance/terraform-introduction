#--------------------------------------------------------------
# This module creates all networking resources
#--------------------------------------------------------------

variable "name"                   { default = "bastion"}
variable "vpc_cidr"               { }
variable "azs"                    { }
variable "region"                 { }
variable "private_subnets"        { }
variable "public_subnets"         { }
variable "key_name"               { }
variable "sub_domain"             { }
variable "bastion_instance_type"  { }
variable "bastion_nat_ami"        { }
variable "vpn_ip"                 { }
variable "environment"            { }

module "vpc" {
  source = "./../vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
  environment = "${var.environment}"
}

module "public_subnet" {
  source = "./../public_subnet"

  name   = "${var.name}-public"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${var.public_subnets}"
  azs    = "${var.azs}"
}

module "bastion" {
  source = "./../bastion"

  name                  = "${var.name}"
  environment           = "${var.environment}"
  vpc_id                = "${module.vpc.vpc_id}"
  vpc_cidr              = "${module.vpc.vpc_cidr}"
  region                = "${var.region}"
  public_subnet_ids     = "${module.public_subnet.subnet_ids}"
  key_name              = "${var.key_name}"
  instance_type         = "${var.bastion_instance_type}"
  bastion_nat_ami       = "${var.bastion_nat_ami}"
  vpn_ip                = "${var.vpn_ip}"
}

module "nat_gateway" {
  source = "./../nat_gateway"

  azs               = "${var.azs}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

module "private_subnet" {
  source = "./../private_subnet"

  name   = "${var.name}-private"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${var.private_subnets}"
  azs    = "${var.azs}"

  nat_gateway_ids  = "${module.nat_gateway.nat_gateway_ids}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${concat(split(",", module.public_subnet.subnet_ids), split(",", module.private_subnet.subnet_ids))}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags { Name = "${var.name}-all" }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPC
output "vpc_id"   { value = "${module.vpc.vpc_id}" }
output "vpc_cidr" { value = "${module.vpc.vpc_cidr}" }

# Subnets
output "public_subnet_ids"    { value = "${module.public_subnet.subnet_ids}" }
output "private_subnet_ids"   { value = "${module.private_subnet.subnet_ids}" }

# Bastion
output "bastion_user"       { value = "${module.bastion.user}" }
output "bastion_private_ip" { value = "${module.bastion.private_ip}" }
output "bastion_public_ip"  { value = "${module.bastion.public_ip}" }

output "default_security_group_id" { value = "${aws_security_group.allow_all.id}" }


