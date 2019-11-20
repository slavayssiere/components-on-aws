resource "aws_security_group" "priv-alb-sg" {
  count = var.enable_private_alb ? 1 : 0
  name        = "priv-alb-sg-${terraform.workspace}"
  description = "Security group for web ASG"
  vpc_id      = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ips_whitelist
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.component_network.outputs.vpc_cidr]
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

resource "aws_security_group_rule" "allow_priv-alb_web" {
  count = var.enable_private_alb ? 1 : 0
  type            = "egress"
  from_port       = var.port
  to_port         = var.port
  protocol        = "tcp"

  source_security_group_id = aws_security_group.web-asg-sg.id
  security_group_id = aws_security_group.priv-alb-sg.0.id
}

resource "aws_lb" "priv-alb" {
  count = var.enable_private_alb ? 1 : 0
  name               = "priv-alb-${terraform.workspace}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.priv-alb-sg.0.id}"]
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

resource "aws_route53_record" "priv-alb-dns" {
  count = var.enable_private_alb ? 1 : 0
  zone_id = "${data.terraform_remote_state.component_network.outputs.private_dns_zone_id}"
  name    = "${var.dns-name}.${data.terraform_remote_state.component_network.outputs.private_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.priv-alb.0.dns_name}"]
}

resource "aws_lb_listener" "priv-alb" {
  count = var.enable_private_alb ? 1 : 0
  load_balancer_arn = "${aws_lb.priv-alb.0.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.priv-tg.id}"
  }
}
