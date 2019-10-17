data "aws_route53_zone" "public" {
  name         = "${var.public_dns}"
  private_zone = false
}

resource "aws_route53_record" "bastion-dns" {
  zone_id = "${data.aws_route53_zone.public.zone_id}"
  name    = "bastion.${var.public_dns}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.bastion.public_dns}"]
}

