output "sn_public_a_id" {
  value = aws_subnet.demo_sn_public_a.id
}

output "sn_public_b_id" {
  value = aws_subnet.demo_sn_public_b.id
}

output "sn_public_c_id" {
  value = aws_subnet.demo_sn_public_c.id
}

output "sn_private_a_id" {
  value = aws_subnet.demo_sn_private_a.id
}

output "sn_private_b_id" {
  value = aws_subnet.demo_sn_private_b.id
}

output "sn_private_c_id" {
  value = aws_subnet.demo_sn_private_c.id
}

output "sn_private_array" {
  value = [
    aws_subnet.demo_sn_private_a.id,
    aws_subnet.demo_sn_private_b.id,
    aws_subnet.demo_sn_private_c.id
  ]
}

output "vpc_id" {
  value = aws_vpc.demo_vpc.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "private_dns_zone" {
  value = var.private_dns_zone
}

output "private_dns_zone_id" {
  value = aws_route53_zone.demo_private_zone.zone_id
}

output "public_dns_zone" {
  value = "${terraform.workspace}.${var.public_dns}"
}

output "public_dns_zone_id" {
  value = aws_route53_zone.soa-public-dns.zone_id
}

output "account_id" {
  value = var.account_id
}