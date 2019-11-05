
resource "aws_route53_record" "master-internal-dns" {
  zone_id = "${data.terraform_remote_state.component-network.outputs.private_dns_zone_id}"
  name    = "${var.dns-name}.${data.terraform_remote_state.component-network.outputs.private_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.rds-instance.address}"]
}