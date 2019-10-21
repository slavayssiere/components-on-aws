resource "aws_lb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb_sg.id}"]
  subnets            = [
      "${data.terraform_remote_state.layer-base.outputs.sn_public_a_id}",
      "${data.terraform_remote_state.layer-base.outputs.sn_public_b_id}",
      "${data.terraform_remote_state.layer-base.outputs.sn_public_c_id}"
    ]

  enable_deletion_protection = false

  access_logs {
    enabled = false
  }

  tags = {
    Environment = "test"
  }
}

resource "aws_lb_listener_certificate" "public_alb" {
  listener_arn    = "${aws_lb_listener.public_alb.arn}"
  certificate_arn = "${aws_acm_certificate.public_alb.arn}"
}

resource "aws_lb_listener" "public_alb" {
  load_balancer_arn = "${aws_lb.public_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_lb_listener_certificate.public_alb.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${data.terraform_remote_state.layer-eks.outputs.public-target-group}"
  }
}