
resource "aws_route53_zone" "demo_private_zone" {
  name = "${var.private_dns_zone}"

  vpc {
    vpc_id = "${aws_vpc.demo_vpc.id}"
  }

  tags = {
    Environment = "private_hosted_zone"
  }
}
