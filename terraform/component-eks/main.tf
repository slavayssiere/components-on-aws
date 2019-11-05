provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "eks-test/component-eks"
  }
}

data "terraform_remote_state" "component-base" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "${var.bucket_component_base}"
    region = "eu-west-1"
    key    = "eks-test/component-base"
  }
}

data "terraform_remote_state" "component-network" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "${var.bucket_component_base}"
    region = "eu-west-1"
    key    = "eks-test/component-network"
  }
}

variable "bucket_component_base" {
  default = "wescale-slavayssiere-terraform"
}

variable "cluster-name" {
  default = "eks-test"
}

