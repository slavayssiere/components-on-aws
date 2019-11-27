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

resource "aws_lb_target_group" "priv-tg" {
  name     = "priv-tg-${terraform.workspace}"
  port     = "${var.port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  health_check {
    path = "${var.health_check}"
    port = "${var.health_check_port}"
  }
}

# uncomment when AWS do is taff : https://github.com/terraform-providers/terraform-provider-aws/issues/5361

resource "aws_autoscaling_group" "web-asg" {
  name                 = "web-asg-${terraform.workspace}"
  desired_capacity     = var.node-count
  launch_configuration = "${aws_launch_configuration.web-lc.id}"
  max_size             = var.max-node-count
  min_size             = var.min-node-count
  enabled_metrics = [
    "GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity",
    "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances",
    "GroupTerminatingInstances", "GroupTotalInstances", "GroupInServiceCapacity",
    "GroupPendingCapacity", "GroupTerminatingCapacity", "GroupStandbyCapacity",
    "GroupTotalCapacity"
  ]

  vpc_zone_identifier = [
    "${data.terraform_remote_state.component_network.outputs.sn_private_a_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_private_b_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_private_c_id}"
  ]

  target_group_arns = [
    "${aws_lb_target_group.web-tg.arn}",
    "${aws_lb_target_group.priv-tg.arn}"
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

  tag {
    key                 = "Monitoring"
    value               = "9100"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "web-asg-policy" {
  name                   = "web-asg-policy-${terraform.workspace}"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.name}"
}

// resource "aws_cloudformation_stack" "autoscaling_group" {
//   name = "web-asg-${terraform.workspace}"
 
//   template_body = <<EOF
// Description: "web-asg-${terraform.workspace}"
// Resources:
//   ASG:
//     Type: AWS::AutoScaling::AutoScalingGroup
//     Properties:
//       VPCZoneIdentifier: ["${data.terraform_remote_state.component_network.outputs.sn_private_a_id}", "${data.terraform_remote_state.component_network.outputs.sn_private_b_id}","${data.terraform_remote_state.component_network.outputs.sn_private_c_id}"]
//       LaunchConfigurationName: "${aws_launch_configuration.web-lc.id}"
//       MinSize: "${var.min-node-count}"
//       MaxSize: "${var.max-node-count}"
//       DesiredCapacity: "${var.node-count}"
//       HealthCheckType: EC2
//       TargetGroupARNs:
//         - "${aws_lb_target_group.web-tg.arn}"
//         - "${aws_lb_target_group.priv-tg.arn}"
//       MetricsCollection:
//         - Granularity: "1Minute"
//           Metrics: 
//             - "GroupMinSize"
//             - "GroupMaxSize"
//             - "GroupDesiredCapacity"
//             - "GroupInServiceInstances"
//             - "GroupPendingInstances"
//             - "GroupStandbyInstances"
//             - "GroupTerminatingInstances"
//             - "GroupTotalInstances"
//             - "GroupInServiceCapacity"
//             - "GroupPendingCapacity"
//             - "GroupTerminatingCapacity"
//             - "GroupStandbyCapacity"
//             - "GroupTotalCapacity"
//       Tags:
//         - Key: Monitoring
//           Value: 9100
//           PropagateAtLaunch: "true"
//         - Key: Plateform
//           Value: "${terraform.workspace}"
 
//     CreationPolicy:
//       AutoScalingCreationPolicy:
//         MinSuccessfulInstancesPercent: 80
//       ResourceSignal:
//         Count: "5"
//         Timeout: PT10M
//     UpdatePolicy:
//     # Ignore differences in group size properties caused by scheduled actions
//       AutoScalingScheduledAction:
//         IgnoreUnmodifiedGroupSizeProperties: true
//       AutoScalingRollingUpdate:
//         MaxBatchSize: "${var.max-node-count}"
//         MinInstancesInService: "${var.min-node-count}"
//         MinSuccessfulInstancesPercent: 80
//         PauseTime: PT10M
//         SuspendProcesses:
//           - HealthCheck
//           - ReplaceUnhealthy
//           - AZRebalance
//           - AlarmNotification
//           - ScheduledActions
//         WaitOnResourceSignals: true
//     DeletionPolicy: Retain
//   EOF
// }
