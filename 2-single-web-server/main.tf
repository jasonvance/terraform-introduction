provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  }

resource "aws_key_pair" "site_key" {
  key_name   = "id_rsa_slcdevopsdays"
  public_key = "${var.public_key}"

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
  name = "web_server_sg"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = "${aws_instance.web_server.public_ip}"
}