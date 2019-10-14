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

output "vpc_id" {
  value = "${aws_vpc.my_vpc.id}"
}

output "subnet_id" {
  value = "${aws_subnet.my_subnet.id}"
}

output "gateway_id" {
  value = "${aws_internet_gateway.my_gw.id}"
}
output "route_table_id" {
  value = "${aws_route_table.my_route_table.id}"
}
output "route_table_association_id" {
  value = "${aws_route_table_association.my_route_table_assoc.id}"
}
