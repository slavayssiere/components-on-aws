resource "aws_lb" "private_alb" {
  name               = "private-alb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${data.terraform_remote_state.component_eks.outputs.allow_https_id}"]
  subnets = [
    "${data.terraform_remote_state.component_network.outputs.sn_public_a_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_public_b_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_public_c_id}"
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
  zone_id = "${data.terraform_remote_state.component_base.outputs.public_dns_zone_id}"
  name    = "private.${data.terraform_remote_state.component_base.outputs.public_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.private_alb.dns_name}"]
}

# TODO: add OIDC management in private

resource "aws_lb_listener" "private_alb" {
  load_balancer_arn = "${aws_lb.private_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.terraform_remote_state.component_base.outputs.wildcard-acme}"

  // default_action {
  //   type = "authenticate-cognito"

  //   authenticate_cognito {
  //     user_pool_arn       = "${aws_cognito_user_pool.pool.arn}"
  //     user_pool_client_id = "${aws_cognito_user_pool_client.client.id}"
  //     user_pool_domain    = "${aws_cognito_user_pool_domain.domain.domain}"
  //   }
  // }

  default_action {
    type             = "forward"
    target_group_arn = "${data.terraform_remote_state.component_eks.outputs.private-target-group}"
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