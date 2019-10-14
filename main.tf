variable "vpc_cidr" {
}
variable "aza_name" {
}
variable "aza_cidr" {
}
provider "aws" {
  region     = "eu-west-1"
}
resource "aws_vpc" "my_vpc" {
}
resource "aws_subnet" "my_subnet" {
}
resource "aws_internet_gateway" "my_gw" {
}
resource "aws_route_table" "my_route_table" {
}
resource "aws_route_table_association" "my_route_table_assoc" {
}
output "vpc_id" {
}
output "subnet_id" {
}
output "gateway_id" {
}
output "route_table_id" {
}
output "route_table_association_id" {
}

