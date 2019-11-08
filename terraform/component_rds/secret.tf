resource "aws_secretsmanager_secret" "rds-admin-secret" {
  name = "rds-admin-secret-${terraform.workspace}"
}

resource "aws_secretsmanager_secret_version" "rds-admin-secret" {
  secret_id     = "${aws_secretsmanager_secret.rds-admin-secret.id}"
  secret_string = "${var.password}"
}