provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    key    = "eks-test/component_web"
  }
}

data "terraform_remote_state" "component_base" {
  backend   = "s3"
  workspace = var.workspace-network

  config = {
    bucket = var.bucket_component_state
    region = var.region
    key    = "eks-test/component_base"
  }
}

data "terraform_remote_state" "component_network" {
  backend   = "s3"
  workspace = "${var.workspace-network}"

  config = {
    bucket = var.bucket_component_state
    region = var.region
    key    = "eks-test/component_network"
  }
}


data "terraform_remote_state" "component_bastion" {
  backend   = "s3"
  workspace = "${var.workspace-network}"

  config = {
    bucket = var.bucket_component_state
    region = var.region
    key    = "eks-test/component_bastion"
  }
}

variable "region" {
  type = string
  default = "eu-west-1"
}

variable "bucket_component_state" {}

variable "workspace-network" {}

variable "ami-name" {
  type = string
}

variable "ami-account" {
  type = string
}

variable "dns-name" {
  type = string
}

variable "user-data" {
  default = ""
}

variable "port" {
  default = "80"
}

variable "health_check" {
  default = "/"
}

variable "health_check_port" {
  default = "80"
}

variable "efs_enable" {
  type = bool
  default = false
}

variable "node-count" {
  type = number
  default = 3
}

variable "max-node-count" {
  type = number
  default = 6
}
variable "min-node-count" {
  type = number
  default = 3
}

variable "attach_cw_ro" {
  type = bool
  default = false
}

variable "bastion_enable" {
  type = bool
  default = false
}

variable "ips_whitelist" {
  type = list(string)
}

variable "cognito_list" {
  type = list(number)
  default = []
}

variable "attach_ec2_ro" {
  type = bool
  default = false
}

variable "attach_sns_pub" {
  type = bool
  default = false
}

variable "enable_private_alb" {
  type = bool
  default = false
}

variable "enable_public_alb" {
  type = bool
  default = true
}
