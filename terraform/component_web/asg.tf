data "aws_ami" "custom-ami" {
  filter {
    name   = "name"
    values = ["${var.ami-name}"]
  }

  most_recent = true
  owners      = ["${var.ami-account}"]
}

resource "aws_iam_role" "web-role" {
  name = "web-role-${terraform.workspace}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "web-role-cw-attach" {
  count = var.attach_cw_ro ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  role       = "${aws_iam_role.web-role.name}"
}

resource "aws_iam_role_policy_attachment" "ssm-policy-attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = "${aws_iam_role.web-role.name}"
}

resource "aws_iam_instance_profile" "web-ip" {
  name = "ip-${terraform.workspace}"
  role = "${aws_iam_role.web-role.name}"
}

resource "aws_launch_configuration" "web-lc" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.web-ip.name}"
  image_id         = "${data.aws_ami.custom-ami.id}"
  instance_type    = "m5.large"
  name_prefix      = "terraform-eks-demo-${terraform.workspace}"
  security_groups  = ["${aws_security_group.web-asg-sg.id}"]
  user_data_base64 = "${base64encode(var.user-data)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "web-tg" {
  name     = "web-tg-${terraform.workspace}"
  port     = "${var.port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  health_check {
    path = "${var.health_check}"
    port = "${var.health_check_port}"
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name                 = "web-asg-${terraform.workspace}"
  desired_capacity     = var.node-count
  launch_configuration = "${aws_launch_configuration.web-lc.id}"
  max_size             = var.max-node-count
  min_size             = var.min-node-count
  vpc_zone_identifier = [
    "${data.terraform_remote_state.component_network.outputs.sn_private_a_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_private_b_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_private_c_id}"
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