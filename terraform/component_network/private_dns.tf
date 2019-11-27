
resource "aws_route53_zone" "private_zone" {
  name = "${var.private_dns_zone}"

  vpc {
    vpc_id = "${aws_vpc.pf_vpc.id}"
  }

  tags = {
    Environment = "private_hosted_zone"
  }
}
