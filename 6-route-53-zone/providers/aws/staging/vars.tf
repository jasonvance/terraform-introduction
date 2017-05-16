#provide access to your system
variable "access_key"               {default = ""}
variable "secret_key"               {default = ""}
variable "public_key"               {default = ""}
variable "key_name"                 { default = "id_rsa_slcdevopsdays"}

variable "environment"              { default = "staging" }
variable "region"                   { default = "us-east-1" }
variable "sub_domain"               { default = "staging" }
variable "service"                  { default = "webserver"}

#need to add this for access to the bastion
variable "vpn_ip"                   { default = "98.202.208.66/32"}
variable "vpc_cidr"                 { default = "10.0.0.0/16" }
variable "azs"                      { default = "us-east-1c,us-east-1d,us-east-1a,us-east-1b,us-east-1e" }
variable "private_subnets"          { default = "10.0.101.0/24,10.0.102.0/24,10.0.103.0/24" }
variable "public_subnets"           { default = "10.0.104.0/24,10.0.105.0/24,10.0.106.0/24" }
variable "bastion_instance_type"    { default = "t2.micro" }
variable "bastion_nat_ami"          { default = "ami-500d8546" }
variable "r53_zone_id"              { default = "Z2JLZFNGI3N8WO" }
