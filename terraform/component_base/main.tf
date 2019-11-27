provider "aws" {
  region  = "${var.region}"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  # can be changed in def_component in "init" 
  backend "s3" {
    key    = "eks-test/component_base"
  }
}

variable "account_id" {
  type = string
}

variable "region" {
  default = "eu-west-1"
}

variable "public_dns" {}

variable "enable_public_dns" {
  default = true
  type = bool
}

variable "monthly_billing_threshold" {
  type = number
  default = 10000
}

# Currency is optional and defaults to USD
variable "currency" {
  default = "USD"
}

variable "email_address" {}
