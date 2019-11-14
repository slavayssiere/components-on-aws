resource "aws_security_group" "web-asg-sg" {
  name        = "web-asg-sg-${terraform.workspace}"
  description = "Security group for web ASG"
  vpc_id      = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
      "Name", "web-asg-sg-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_security_group_rule" "allow_ssh_bastion" {
  count = var.bastion_enable ? 1 : 0
  type            = "ingress"
  from_port       = "22"
  to_port         = "22"
  protocol        = "tcp"

  source_security_group_id = data.terraform_remote_state.component_bastion.outputs.sg_bastion
  security_group_id = aws_security_group.web-asg-sg.id
}
