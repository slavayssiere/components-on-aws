resource "aws_security_group" "demo-cluster" {
  name        = "terraform-eks-demo-cluster-${terraform.workspace}"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${data.terraform_remote_state.layer-base.outputs.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
      "Name", "terraform-eks-demo-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

#add IP from home to connect to master
resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${data.terraform_remote_state.layer-bastion.outputs.bastion_private_ip}/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.demo-cluster.id}"
  to_port           = 443
  type              = "ingress"
}