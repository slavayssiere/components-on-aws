provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "eks-test/component_link"
  }
}

data "terraform_remote_state" "component_web" {
  backend   = "s3"
  workspace = "${var.workspace-web}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_web"
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
variable "workspace-web" {}
variable "workspace-rds" {}
