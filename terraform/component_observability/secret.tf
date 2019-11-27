resource "aws_secretsmanager_secret" "grafana-secret" {
  name = "grafana-secret-${terraform.workspace}-${formatdate("hh-mm-DD-MMM-YYYY", timestamp())}"
}

resource "aws_ssm_parameter" "grafana-secret-path" {
  name  = "grafana-password-${var.plateform_name}"
  type  = "String"
  value = "grafana-secret-${terraform.workspace}-${formatdate("hh-mm-DD-MMM-YYYY", timestamp())}"
}

resource "aws_secretsmanager_secret_version" "grafana-secret" {
  secret_id     = "${aws_secretsmanager_secret.grafana-secret.id}"
  secret_string = "${var.grafana_password}"
}