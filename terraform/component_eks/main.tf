provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    key    = "eks-test/component_eks"
  }
}

data "terraform_remote_state" "component_base" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = var.bucket_component_state
    region = var.region
    key    = "eks-test/component_base"
  }
}

data "terraform_remote_state" "component_network" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = var.bucket_component_state
    region = var.region
    key    = "eks-test/component_network"
  }
}

variable "bucket_component_state" {}

variable "cluster-name" {
  default = "eks-test"
}

variable "region" {
  type = string
  default = "eu-west-1"
}

variable "instance_type_node" {
  default = "m4.large"
  type = string
}
