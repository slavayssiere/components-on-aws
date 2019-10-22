provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "eks-test/layer-bastion"
  }
}

data "terraform_remote_state" "layer-base" {
  backend = "s3"

  config = {
    bucket = "${var.bucket_layer_base}"
    region = "eu-west-1"
    key    = "eks-test/layer-base"

    workspaces = {
      name = "${terraform.workspace}"
    }
  }
}

variable "bucket_layer_base" {
  default = "wescale-slavayssiere-terraform"
}

variable "public_dns" {
  default = "aws-wescale.slavayssiere.fr."
}
