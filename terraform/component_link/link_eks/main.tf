provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    key    = "eks-test/component_link_eks"
  }
}

data "terraform_remote_state" "component_eks" {
  backend   = "s3"
  workspace = "${var.workspace-eks}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_eks"
  }
}

data "terraform_remote_state" "component_rds" {
  backend   = "s3"
  workspace = "${var.workspace-rds}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_rds"
  }
}

variable "bucket_component_state" {}
variable "workspace-eks" {}
variable "workspace-rds" {}
