resource "aws_security_group" "rds-sec-group" {
  name        = "rds-sec-group-${terraform.workspace}"
  description = "Allow rds traffic"
  vpc_id      = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  tags = "${
    map(
      "Name", "rds-subnet-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}