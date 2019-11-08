resource "aws_db_subnet_group" "rds-subnet" {
  name = "rds-subnet-${terraform.workspace}"
  subnet_ids = [
    "${data.terraform_remote_state.component-network.outputs.sn_private_a_id}",
    "${data.terraform_remote_state.component-network.outputs.sn_private_b_id}",
    "${data.terraform_remote_state.component-network.outputs.sn_private_c_id}"
  ]

  tags = "${
    map(
      "Name", "rds-subnet-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}