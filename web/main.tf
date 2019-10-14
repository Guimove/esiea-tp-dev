terraform {
  backend "s3" {
    bucket = "engieit-noprod-agora-terraform"
    key    = "web/web1.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "engieit-noprod-agora-terraform"
    key    = "vpc/vpc.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_security_group" "sg_allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "userdata" {
  template = "${file("userdata.tpl")}"

  vars {
    http_proxy = "http://127.0.0.1:8888/"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "my_keypair" {
  key_name   = "iac_keypair"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "ec2_web" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t3.micro"
  key_name               = "${aws_key_pair.my_keypair.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_allow_http.id}"]
  user_data              = "${data.template_file.userdata.rendered}"
  subnet_id              = "${data.terraform_remote_state.vpc.subnet_id}"

  tags {
    Name = "my_web"
  }
}
