provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "eks-test/component-alb"
  }
}

data "terraform_remote_state" "component-base" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "${var.bucket_layer_base}"
    region = "eu-west-1"
    key    = "eks-test/component-base"
  }
}

data "terraform_remote_state" "component-eks" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "${var.bucket_layer_base}"
    region = "eu-west-1"
    key    = "eks-test/component-eks"
  }
}


data "terraform_remote_state" "component-bastion" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "${var.bucket_layer_base}"
    region = "eu-west-1"
    key    = "eks-test/component-bastion"
  }
}

variable "bucket_layer_base" {
  default = "wescale-slavayssiere-terraform"
}

variable "cluster-name" {
  default = "eks-test"
}

