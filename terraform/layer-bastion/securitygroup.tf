resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_${terraform.workspace}"
  description = "Allow SSH traffic"
  vpc_id      = "${data.terraform_remote_state.layer-base.outputs.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow https for kops/kubectl/helm install
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow http for ansible install
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow ssh for private instance ssh
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.layer-base.outputs.vpc_cidr}"]
  }

  # allow 8080 for traefik dashboard (private vpc cidr)
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.layer-base.outputs.vpc_cidr}"]
  }

  tags = "${
    map(
      "Name", "sg_for_bastion-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}
