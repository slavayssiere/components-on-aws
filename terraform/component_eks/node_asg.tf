data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.demo.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We implement a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.demo.endpoint}' --b64-cluster-ca '${aws_eks_cluster.demo.certificate_authority.0.data}' '${var.cluster-name}-${terraform.workspace}'
USERDATA
}

resource "aws_launch_configuration" "demo" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.demo-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks-demo-${terraform.workspace}"
  security_groups             = ["${aws_security_group.demo-node.id}"]
  user_data_base64            = "${base64encode(local.demo-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "eks-nodes-public-ingress" {
  name     = "eks-nodes-public-ingress-${terraform.workspace}"
  port     = 32001
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  health_check {
    path = "/ping"
  }
}


resource "aws_lb_target_group" "eks-nodes-private-ingress" {
  name     = "eks-nds-priv-ing-${terraform.workspace}"
  port     = 32002
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  health_check {
    path = "/ping"
  }
}

resource "aws_autoscaling_group" "demo" {
  desired_capacity     = 3
  launch_configuration = "${aws_launch_configuration.demo.id}"
  max_size             = 6
  min_size             = 3
  name                 = "terraform-eks-demo-${terraform.workspace}"
  vpc_zone_identifier = [
    "${data.terraform_remote_state.component_network.outputs.sn_private_a_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_private_b_id}",
    "${data.terraform_remote_state.component_network.outputs.sn_private_c_id}"
  ]

  target_group_arns = [
    "${aws_lb_target_group.eks-nodes-public-ingress.arn}",
    "${aws_lb_target_group.eks-nodes-private-ingress.arn}"
  ]


  tag {
    key                 = "Name"
    value               = "terraform-eks-demo-${terraform.workspace}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Plateform"
    value               = "${terraform.workspace}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}-${terraform.workspace}"
    value               = "owned"
    propagate_at_launch = true
  }
}