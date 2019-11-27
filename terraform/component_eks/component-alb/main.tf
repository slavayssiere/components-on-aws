provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    key    = "eks-test/component_alb"
  }
}

data "terraform_remote_state" "component_base" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_base"
  }
}

data "terraform_remote_state" "component_network" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_network"
  }
}

data "terraform_remote_state" "component_eks" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_eks"
  }
}


data "terraform_remote_state" "component_bastion" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_bastion"
  }
}

variable "bucket_component_state" {}
