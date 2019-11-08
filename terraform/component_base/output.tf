
output "public_dns_zone" {
  value = "${terraform.workspace}.${var.public_dns}"
}

output "public_dns_zone_id" {
  value = aws_route53_zone.soa-public-dns.zone_id
}

output "account_id" {
  value = var.account_id
}