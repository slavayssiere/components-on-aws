resource "aws_lb" "private_alb" {
  name               = "private-alb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${data.terraform_remote_state.component-eks.outputs.allow_https_id}"]
  subnets = [
    "${data.terraform_remote_state.component-network.outputs.sn_public_a_id}",
    "${data.terraform_remote_state.component-network.outputs.sn_public_b_id}",
    "${data.terraform_remote_state.component-network.outputs.sn_public_c_id}"
  ]

  enable_deletion_protection = false

  tags = "${
    map(
      "Name", "private-alb-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_route53_record" "private_alb_dns" {
  zone_id = "${data.terraform_remote_state.component-base.outputs.public_dns_zone_id}"
  name    = "private.${data.terraform_remote_state.component-base.outputs.public_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.private_alb.dns_name}"]
}

resource "aws_acm_certificate" "private_alb" {
  domain_name       = "${aws_route53_record.private_alb_dns.fqdn}"
  validation_method = "DNS"

  tags = "${
    map(
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_route53_record" "private_alb_cert_validation" {
  name    = "${aws_acm_certificate.private_alb.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.private_alb.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.terraform_remote_state.component-base.outputs.public_dns_zone_id}"
  records = ["${aws_acm_certificate.private_alb.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "private_alb_cert_validation" {
  certificate_arn         = "${aws_acm_certificate.private_alb.arn}"
  validation_record_fqdns = ["${aws_route53_record.private_alb_cert_validation.fqdn}"]
}

resource "aws_lb_listener" "private_alb" {
  load_balancer_arn = "${aws_lb.private_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate_validation.private_alb_cert_validation.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${data.terraform_remote_state.component-eks.outputs.private-target-group}"
  }
}

resource "aws_lb_listener" "private_alb_redirect_https" {
  load_balancer_arn = "${aws_lb.private_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}