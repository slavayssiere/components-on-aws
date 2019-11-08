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


resource "aws_acm_certificate" "wildcard-acme" {
  domain_name       = "*.${terraform.workspace}.${var.public_dns}"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }
}

resource "aws_route53_record" "wildcard-acme-cert-validation" {
  name    = "${aws_acm_certificate.wildcard-acme.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.wildcard-acme.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.soa-public-dns.id}"
  records = ["${aws_acm_certificate.wildcard-acme.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "web-alb-cert-validation" {
  certificate_arn         = "${aws_acm_certificate.wildcard-acme.arn}"
  validation_record_fqdns = ["${aws_route53_record.wildcard-acme-cert-validation.fqdn}"]
}