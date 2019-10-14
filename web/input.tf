variable "vpc_region" {
  type    = "string"
  default = "eu-west-1"
}

provider "aws" {
  region     = "${var.vpc_region}"
}

terraform {
  backend "s3" {
    bucket = "mytf-state"
    key    = "web/terraform.tfstate"
    region = "eu-west-1"
  }
}
