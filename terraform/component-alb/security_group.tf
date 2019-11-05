resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${data.terraform_remote_state.component-base.outputs.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 32001
    to_port         = 32002
    protocol        = "tcp"
    security_groups = ["${data.terraform_remote_state.component-eks.outputs.nodes_sg}"]
  }

  tags = {
    Name = "allow_all"
  }
}

###
### LB to worker
###
resource "aws_security_group_rule" "public-ingress-node" {
  description              = "Allow LB to nodes"
  from_port                = 32001
  protocol                 = "tcp"
  security_group_id        = "${data.terraform_remote_state.component-eks.outputs.nodes_sg}"
  source_security_group_id = "${aws_security_group.allow_https.id}"
  to_port                  = 32002
  type                     = "ingress"
}