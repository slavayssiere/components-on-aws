
resource "aws_security_group_rule" "allow_web" {
  count = var.is_web ? 1 : 0
  type            = "ingress"
  from_port       = data.terraform_remote_state.component_rds.outputs.rds-port
  to_port         = data.terraform_remote_state.component_rds.outputs.rds-port
  protocol        = "tcp"

  source_security_group_id = data.terraform_remote_state.component_web.outputs.web-sg
  security_group_id = data.terraform_remote_state.component_rds.outputs.rds-sg
}


resource "aws_security_group_rule" "allow_eks" {
  count = var.is_eks ? 1 : 0
  type            = "ingress"
  from_port       = data.terraform_remote_state.component_rds.outputs.rds-port
  to_port         = data.terraform_remote_state.component_rds.outputs.rds-port
  protocol        = "tcp"

  source_security_group_id = data.terraform_remote_state.component_eks.outputs.nodes_sg
  security_group_id = data.terraform_remote_state.component_rds.outputs.rds-sg
}
