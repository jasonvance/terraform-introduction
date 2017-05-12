provider "aws" {
  region      = "us-east-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_key_pair" "site_key" {
  key_name                = "id_rsa_slcdevopsdays"
  public_key              = "${var.public_key}"

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_instance" "web_server" {
  #busybox default on Ubuntu
  ami                         = "ami-2d39803a"
  count                       = 1
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.web_server_sg.name}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, Salt Lake City DevOps Days!" > index.html
              nohup busybox httpd -f -p 80 &
              EOF
  tags {
    Name = "single-webserver"
  }
}

resource "aws_security_group" "web_server_sg" {
  name          = "web_server_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol              = -1
    from_port             = 0
    to_port               = 0
    cidr_blocks           = ["0.0.0.0/0"]
  }
    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "web_server_lc" {
  image_id                = "ami-2d39803a"
  instance_type           = "t2.micro"
  security_groups         = ["${aws_security_group.web_server_sg.name}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, Salt Lake City DevOps Days!" > index.html
              nohup busybox httpd -f -p 80 &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  launch_configuration  = "${aws_launch_configuration.web_server_lc.id}"
  availability_zones    = ["${data.aws_availability_zones.all.names}"]

  load_balancers = ["${aws_elb.web_server_elb.name}"]
  health_check_type = "ELB"

  min_size              = 2
  max_size              = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "web_server_elb" {
  name                  = "terraform-elb-example"
  security_groups       = ["${aws_security_group.web_server_sg.id}"]
  availability_zones    = ["${data.aws_availability_zones.all.names}"]
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
  listener {
    lb_port             = 80
    lb_protocol         = "http"
    instance_port       = "80"
    instance_protocol   = "http"
  }
}

output "elb_dns_name" {
  value = "${aws_elb.web_server_elb.dns_name}"
}

output "public_ip" {
  value = "${aws_instance.web_server.public_ip}"
}