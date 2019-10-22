resource "aws_route53_record" "bastion-dns" {
  zone_id = "${data.terraform_remote_state.layer-base.outputs.public_dns_zone_id}"
  name    = "bastion.${data.terraform_remote_state.layer-base.outputs.public_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.bastion.public_dns}"]
}

