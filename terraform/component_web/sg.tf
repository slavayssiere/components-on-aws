resource "aws_security_group" "web-asg-sg" {
  name        = "web-asg-sg-${terraform.workspace}"
  description = "Security group for web ASG"
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

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.component_network.outputs.vpc_cidr]
  }

  # for node exporter
  # TODO: do this in link component
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.component_network.outputs.vpc_cidr]
  }

  egress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.component_network.outputs.vpc_cidr]
  }

  egress {
    from_port   = 31900
    to_port     = 31900
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.component_network.outputs.vpc_cidr]
  }

  egress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.component_network.outputs.vpc_cidr]
  }
  # TODO: /do this in link component

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
