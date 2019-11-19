resource "aws_secretsmanager_secret" "rds-admin-secret" {
  name = "rds-admin-secret-${terraform.workspace}-${formatdate("hh-mm-DD-MMM-YYYY", timestamp())}"
}

resource "aws_ssm_parameter" "rds-admin-secret-path" {
  name  = "rds-admin-secret-path-${terraform.workspace}"
  type  = "String"
  value = "rds-admin-secret-${terraform.workspace}-${formatdate("hh-mm-DD-MMM-YYYY", timestamp())}"
}

resource "aws_secretsmanager_secret_version" "rds-admin-secret" {
  secret_id     = "${aws_secretsmanager_secret.rds-admin-secret.id}"
  secret_string = "${var.password}"
}