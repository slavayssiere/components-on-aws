provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "eks-test/component-bastion"
  }
}

data "terraform_remote_state" "component-base" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "${var.bucket_component_state}"
    region = "eu-west-1"
    key    = "eks-test/component-base"
  }
}

data "terraform_remote_state" "component-network" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "${var.bucket_component_state}"
    region = "eu-west-1"
    key    = "eks-test/component-network"
  }
}

data "terraform_remote_state" "component-eks" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "${var.bucket_component_state}"
    region = "eu-west-1"
    key    = "eks-test/component-eks"
  }
}

variable "bucket_component_state" {
  default = "wescale-slavayssiere-terraform"
}

variable "enable_eks" {
  type = bool
}