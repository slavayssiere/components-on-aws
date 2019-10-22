data "aws_route53_zone" "public" {
  name         = "${var.public_dns}"
  private_zone = false
}

