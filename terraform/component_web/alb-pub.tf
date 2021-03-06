resource "aws_security_group" "alb-sg" {
  count = var.enable_public_alb ? 1 : 0
  name        = "alb-sg-${terraform.workspace}"
  description = "Security group for web ASG"
  vpc_id      = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ips_whitelist
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ips_whitelist
  }

  tags = "${
    map(
      "Name", "web-asg-sg-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_security_group_rule" "allow_alb_web" {
  count = var.enable_public_alb ? 1 : 0
  type            = "egress"
  from_port       = var.port
  to_port         = var.port
  protocol        = "tcp"

  source_security_group_id = aws_security_group.web-asg-sg.id
  security_group_id = aws_security_group.alb-sg.0.id
}

resource "aws_lb" "web-alb" {
  count = var.enable_public_alb ? 1 : 0
  name               = "web-alb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb-sg.0.id}"]
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
  count = var.enable_public_alb ? 1 : 0
  zone_id = "${data.terraform_remote_state.component_base.outputs.public_dns_zone_id}"
  name    = "${var.dns-name}.${data.terraform_remote_state.component_base.outputs.public_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.web-alb.0.dns_name}"]
}

# TODO: enable OIDC if needed
resource "aws_lb_listener" "web-alb" {
  count = var.enable_public_alb ? 1 : 0
  load_balancer_arn = "${aws_lb.web-alb.0.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.terraform_remote_state.component_base.outputs.wildcard-acme}"

  // dynamic "default_action" {
  //   for_each = var.cognito_list
  //   content {
  //     type = "authenticate-cognito"

  //     authenticate_cognito {
  //       user_pool_arn       = "${data.terraform_remote_state.component_base.outputs.user_pool_arn}"
  //       user_pool_client_id = "${data.terraform_remote_state.component_base.outputs.user_pool_client_id}"
  //       user_pool_domain    = "${data.terraform_remote_state.component_base.outputs.user_pool_domain}"
  //     }
  //   }
  // }

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web-tg.id}"
  }
}

resource "aws_lb_listener" "web-alb-redirect-https" {
  count = var.enable_public_alb ? 1 : 0
  load_balancer_arn = "${aws_lb.web-alb.0.arn}"
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