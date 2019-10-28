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
