resource "aws_launch_configuration" "web-lc" {
  associate_public_ip_address = false
//   iam_instance_profile        = "${aws_iam_instance_profile.demo-node.name}"
  image_id                    = "${var.ami}"
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks-demo-${terraform.workspace}"
  security_groups             = ["${aws_security_group.web-asg-sg.id}"]
  user_data_base64            = "${base64encode(var.user-data)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "web-tg" {
  name     = "web-tg-${terraform.workspace}"
  port     = "${var.port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.component-network.outputs.vpc_id}"

  health_check {
    path = "${var.health_check}"
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name                 = "web-asg-${terraform.workspace}"
  desired_capacity     = 3
  launch_configuration = "${aws_launch_configuration.web-lc.id}"
  max_size             = 6
  min_size             = 3
  vpc_zone_identifier = [
    "${data.terraform_remote_state.component-network.outputs.sn_private_a_id}",
    "${data.terraform_remote_state.component-network.outputs.sn_private_b_id}",
    "${data.terraform_remote_state.component-network.outputs.sn_private_c_id}"
  ]

  target_group_arns = [
    "${aws_lb_target_group.web-tg.arn}"
  ]


  tag {
    key                 = "Name"
    value               = "web-asg-${terraform.workspace}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Plateform"
    value               = "${terraform.workspace}"
    propagate_at_launch = true
  }
}