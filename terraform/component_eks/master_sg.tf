resource "aws_security_group" "demo-cluster" {
  name        = "terraform-eks-demo-cluster-${terraform.workspace}"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
      "Name", "terraform-eks-demo-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}
