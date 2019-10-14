variable "vpc_cidr" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "aza_name" {
  type    = "string"
  default = "eu-west-1a"
}

variable "aza_cidr" {
  type    = "string"
  default = "10.0.1.0/24"
}

provider "aws" {
  region     = "eu-west-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "my_vpc"
    Group = "my_infra"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = "${aws_vpc.my_vpc.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aza_name}"
  cidr_block              = "${var.aza_cidr}"

  tags {
    Name = "my_subnet"
    Group = "my_infra"
  }
}

resource "aws_internet_gateway" "my_gw" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "my_gateway"
    Group = "my_infra"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my_gw.id}"
  }

  tags {
    Name = "my_route_table"
    Group = "my_infra"
  }
}

resource "aws_route_table_association" "my_route_table_assoc" {
  subnet_id      = "${aws_subnet.my_subnet.id}"
  route_table_id = "${aws_route_table.my_route_table.id}"
}

resource "aws_security_group" "sg_allow_all" {
    name        = "allow_all"
    description = "Allow all inbound traffic"
    vpc_id = "${aws_vpc.my_vpc.id}"
    
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
  public_key = "${file("~/.ssh/id_rsa.iac.pub")}"
}

resource "aws_instance" "ec2_web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.my_keypair.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_allow_all.id}"]
  user_data = "${data.template_file.userdata.rendered}"
  subnet_id = "${aws_subnet.my_subnet.id}"

  tags {
    Name = "my_web"
  }
}



output "vpc_id" {
  value = "${aws_vpc.my_vpc.id}"
}

output "subnet_id" {
  value = "${aws_subnet.my_subnet.id}"
}

output "web" {
  value = "${aws_instance.ec2_web.id}"
}
