provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "eks-test/component_rds"
  }
}

data "terraform_remote_state" "component_network" {
  backend   = "s3"
  workspace = "${var.workspace-network}"

  config = {
    bucket = "${var.bucket_component_state}"
    region = "eu-west-1"
    key    = "eks-test/component_network"
  }
}

variable "workspace-network" {
  type = string
}

variable "bucket_component_state" {
  default = "wescale-slavayssiere-terraform"
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "dns-name" {
  type    = string
  default = "app"
}

variable "password" {
  type = string
}