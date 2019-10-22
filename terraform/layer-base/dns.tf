data "aws_route53_zone" "public" {
  name         = "${var.public_dns}"
  private_zone = false
}

resource "aws_route53_zone" "soa-public-dns" {
  name = "${terraform.workspace}.${var.public_dns}"

  tags = "${
    map(
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_route53_record" "soa-public-dns-ns" {
  zone_id = "${data.aws_route53_zone.public.zone_id}"
  name    = "${terraform.workspace}.${var.public_dns}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.soa-public-dns.name_servers.0}",
    "${aws_route53_zone.soa-public-dns.name_servers.1}",
    "${aws_route53_zone.soa-public-dns.name_servers.2}",
    "${aws_route53_zone.soa-public-dns.name_servers.3}",
  ]
}