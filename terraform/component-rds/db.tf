resource "aws_db_instance" "rds-instance" {

  identifier           = "rds-instance-${terraform.workspace}"
  final_snapshot_identifier = "rds-instance-${terraform.workspace}-final"

  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"

  # to be changed
  username             = "foo"
  password             = "foobarbaz"

  parameter_group_name = "default.mysql5.7"

  vpc_security_group_ids = ["${aws_security_group.rds-sec-group.id}"]

  # must be computed from "plateform" type in YAML
  deletion_protection = "${var.deletion_protection}"
  multi_az            = "${var.multi_az}"

  db_subnet_group_name = "${aws_db_subnet_group.rds-subnet.id}"

  auto_minor_version_upgrade = true
  maintenance_window         = "Sun:00:00-Sun:00:59"

  backup_retention_period = 10
  backup_window           = "02:00-02:59"

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  # autoscaling enabled
  allocated_storage     = 50
  max_allocated_storage = 100

  # tags
  copy_tags_to_snapshot = true

  tags = "${
    map(
      "Name", "rds-subnet-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}