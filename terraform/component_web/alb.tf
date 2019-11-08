resource "aws_lb" "web-alb" {
  name               = "web-alb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.web-asg-sg.id}"]
  subnets = [
    "${data.terraform_remote_state.component_network.outputs.sn_public_a_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_public_b_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_public_c_id}"
  ]

  enable_deletion_protection = false

  tags = {
    Environment = "test"
  }
}

resource "aws_route53_record" "web-alb-dns" {
  zone_id = "${data.terraform_remote_state.component_base.outputs.public_dns_zone_id}"
  name    = "${var.dns-name}.${data.terraform_remote_state.component_base.outputs.public_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.web-alb.dns_name}"]
}

// resource "aws_acm_certificate" "web-alb" {
//   domain_name       = "${aws_route53_record.web-alb-dns.fqdn}"
//   validation_method = "DNS"

//   tags = {
//     Environment = "test"
//   }
// }

// resource "aws_route53_record" "web-alb-cert-validation" {
//   name    = "${aws_acm_certificate.web-alb.domain_validation_options.0.resource_record_name}"
//   type    = "${aws_acm_certificate.web-alb.domain_validation_options.0.resource_record_type}"
//   zone_id = "${data.terraform_remote_state.component_base.outputs.public_dns_zone_id}"
//   records = ["${aws_acm_certificate.web-alb.domain_validation_options.0.resource_record_value}"]
//   ttl     = 60
// }

// resource "aws_acm_certificate_validation" "web-alb-cert-validation" {
//   certificate_arn         = "${aws_acm_certificate.web-alb.arn}"
//   validation_record_fqdns = ["${aws_route53_record.web-alb-cert-validation.fqdn}"]
// }

resource "aws_lb_listener" "web-alb" {
  load_balancer_arn = "${aws_lb.web-alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  // certificate_arn   = "${aws_acm_certificate_validation.web-alb-cert-validation.certificate_arn}"
  certificate_arn   = "${data.terraform_remote_state.component_base.outputs.wildcard-acme}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web-tg.id}"
  }
}

resource "aws_lb_listener" "web-alb-redirect-https" {
  load_balancer_arn = "${aws_lb.web-alb.arn}"
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