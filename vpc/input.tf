variable "vpc_region" {
  type    = "string"
  default = "eu-west-1"
}

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
  region = "${var.vpc_region}"
}

terraform {
  backend "s3" {
    bucket = "mytf-state"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}
