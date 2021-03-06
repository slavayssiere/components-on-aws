provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    key    = "eks-test/component_rds"
  }
}

data "terraform_remote_state" "component_network" {
  backend   = "s3"
  workspace = "${var.workspace-network}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_network"
  }
}

variable "workspace-network" {
  type = string
}

variable "bucket_component_state" {
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

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "snapshot_enable" {
  type = bool
  default = false
}

variable "snapshot_name" {
  type = string
  default = ""
}

variable "engine" {
  default = "mysql"
}

variable "engine_version" {
  default = "5.7"
}

variable "snapshot_rds_paramater_name" {}

variable "instance_type_rds" {
  default = "db.t2.micro"
  type = string
}