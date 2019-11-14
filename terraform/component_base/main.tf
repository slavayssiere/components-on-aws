provider "aws" {
  region  = "${var.region}"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "eks-test/component_base"
  }
}

variable "account_id" {
}

variable "region" {
  default = "eu-west-1"
}

variable "public_dns" {
  default = "aws-wescale.slavayssiere.fr."
}

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
