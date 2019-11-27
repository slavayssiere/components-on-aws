resource "aws_lb" "public_alb" {
  name               = "public-alb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${data.terraform_remote_state.component_eks.outputs.allow_https_id}"]
  subnets = [
    "${data.terraform_remote_state.component_network.outputs.sn_public_a_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_public_b_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_public_c_id}"
  ]

  enable_deletion_protection = false

  tags = {
    Environment = "test"
    Plateform = terraform.workspace
  }
}

resource "aws_route53_record" "public_alb_dns" {
  zone_id = "${data.terraform_remote_state.component_base.outputs.public_dns_zone_id}"
  name    = "public.${data.terraform_remote_state.component_base.outputs.public_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.public_alb.dns_name}"]
}

resource "aws_lb_listener" "public_alb" {
  load_balancer_arn = "${aws_lb.public_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.terraform_remote_state.component_base.outputs.wildcard-acme}"
  default_action {
    type             = "forward"
    target_group_arn = "${data.terraform_remote_state.component_eks.outputs.public-target-group}"
  }
}

resource "aws_lb_listener" "public_alb_redirect_https" {
  load_balancer_arn = "${aws_lb.public_alb.arn}"
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