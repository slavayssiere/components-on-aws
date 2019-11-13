output "rds-sg" {
    value = aws_security_group.rds-sec-group.id
}

output "rds-port" {
    value = var.engine == "mysql" ? "3306" : "5432"
}
