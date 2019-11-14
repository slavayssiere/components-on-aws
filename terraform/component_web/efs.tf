resource "aws_security_group" "nfs-sg" {
  count = var.efs_enable ? 1 : 0
  name        = "nfs-sg-${terraform.workspace}"
  description = "Security group for web ASG"
  vpc_id      = "${data.terraform_remote_state.component_network.outputs.vpc_id}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = ["${aws_security_group.web-asg-sg.id}"]
  }

  tags = "${
    map(
      "Name", "nfs-sg-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_efs_file_system" "web-nfs" {
  count = var.efs_enable ? 1 : 0
  creation_token = "web-nfs-${terraform.workspace}"
}

resource "aws_efs_mount_target" "web-nfs-sn-a" {
  count = var.efs_enable ? 1 : 0
  file_system_id = "${aws_efs_file_system.web-nfs.0.id}"
  subnet_id      = "${data.terraform_remote_state.component_network.outputs.sn_public_a_id}"
  security_groups = ["${aws_security_group.nfs-sg.0.id}"]
}

resource "aws_efs_mount_target" "web-nfs-sn-b" {
  count = var.efs_enable ? 1 : 0
  file_system_id = "${aws_efs_file_system.web-nfs.0.id}"
  subnet_id      = "${data.terraform_remote_state.component_network.outputs.sn_public_b_id}"
  security_groups = ["${aws_security_group.nfs-sg.0.id}"]
}

resource "aws_efs_mount_target" "web-nfs-sn-c" {
  count = var.efs_enable ? 1 : 0
  file_system_id = "${aws_efs_file_system.web-nfs.0.id}"
  subnet_id      = "${data.terraform_remote_state.component_network.outputs.sn_public_c_id}"
  security_groups = ["${aws_security_group.nfs-sg.0.id}"]
}

resource "aws_route53_record" "web-nfs-dns" {
  count = var.efs_enable ? 1 : 0
  zone_id = "${data.terraform_remote_state.component_network.outputs.private_dns_zone_id}"
  name    = "nfs.${data.terraform_remote_state.component_network.outputs.private_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_efs_mount_target.web-nfs-sn-a.0.dns_name}"]
}
