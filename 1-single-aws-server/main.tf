provider "aws" {
  region = "us-east-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "id_rsa_slcdevopsdays"
  public_key = "${var.public_key}"
  lifecycle { create_before_destroy = false }
}

resource "aws_instance" "single_server" {
  count = 1
  ami = "ami-500d8546"
  instance_type = "t2.micro"

  tags {
    Name = "Hello-Word-${count.index}"
  }
}