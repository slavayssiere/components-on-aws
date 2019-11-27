resource "aws_ses_domain_identity" "public-ses" {
  domain = "${terraform.workspace}.${var.public_dns}"
}

data "aws_iam_policy_document" "public-ses" {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = ["${aws_ses_domain_identity.public-ses.arn}"]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource "aws_ses_identity_policy" "example" {
  identity = "${aws_ses_domain_identity.public-ses.arn}"
  name     = "ses-policy-${terraform.workspace}"
  policy   = "${data.aws_iam_policy_document.public-ses.json}"
}

resource "aws_ses_email_identity" "public-ses" {
  email = "no-reply@${terraform.workspace}.${var.public_dns}"
}

resource "aws_ses_domain_identity_verification" "public_ses_verification" {
  domain = "${aws_ses_domain_identity.public-ses.id}"

  depends_on = ["aws_route53_record.public_amazonses_verification_record"]
}

resource "aws_ses_domain_dkim" "public-ses" {
  domain = "${aws_ses_domain_identity.public-ses.domain}"
}

resource "aws_route53_record" "public_amazonses_verification_record" {
  zone_id = "${aws_route53_zone.soa-public-dns.0.id}"
  name    = "_amazonses.${terraform.workspace}.${var.public_dns}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.public-ses.verification_token}"]
}

resource "aws_route53_record" "example_amazonses_dkim_record" {
  count   = 3
  zone_id = "${aws_route53_zone.soa-public-dns.0.id}"
  name    = "${element(aws_ses_domain_dkim.public-ses.dkim_tokens, count.index)}._domainkey.example.com"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.public-ses.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_domain_mail_from" "public-ses" {
  domain           = aws_ses_domain_identity.public-ses.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.public-ses.domain}"
}

# SPF validaton record
resource "aws_route53_record" "spf_mail_from" {
  zone_id = "${aws_route53_zone.soa-public-dns.0.id}"
  name    = aws_ses_domain_mail_from.public-ses.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "spf_domain" {
  zone_id = "${aws_route53_zone.soa-public-dns.0.id}"
  name    = "${terraform.workspace}.${var.public_dns}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "mx_send_mail_from" {
  zone_id = "${aws_route53_zone.soa-public-dns.0.id}"
  name    = aws_ses_domain_mail_from.public-ses.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.region}.amazonses.com"]
}

# Receiving MX Record
resource "aws_route53_record" "mx_receive" {
  name    = "${terraform.workspace}.${var.public_dns}"
  zone_id = "${aws_route53_zone.soa-public-dns.0.id}"
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${var.region}.amazonaws.com"]
}

#
# DMARC TXT Record
#
resource "aws_route53_record" "txt_dmarc" {
  zone_id = "${aws_route53_zone.soa-public-dns.0.id}"
  name    = "_dmarc.${terraform.workspace}.${var.public_dns}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=none; rua=mailto:no-reply@${terraform.workspace}.${var.public_dns};"]
}

#
# SES Receipt Rule
#

// resource "aws_ses_receipt_rule" "main" {
//   name          = format("%s-s3-rule", local.dash_domain)
//   count         = var.enable_incoming_email ? 1 : 0
//   rule_set_name = var.ses_rule_set
//   recipients    = var.from_addresses
//   enabled       = true
//   scan_enabled  = true

//   s3_action {
//     position = 1

//     bucket_name       = var.receive_s3_bucket
//     object_key_prefix = var.receive_s3_prefix
//   }
// }