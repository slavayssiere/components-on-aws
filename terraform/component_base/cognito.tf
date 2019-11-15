resource "aws_cognito_user_pool" "user-pool" {
  name = "pool-${terraform.workspace}"

  alias_attributes          = ["email"]
  auto_verified_attributes  = ["email"]
  mfa_configuration         = "OFF"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "client-pool-${terraform.workspace}"

  generate_secret     = true
  allowed_oauth_flows = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]

  
  read_attributes                         = ["email", "profile"]
  write_attributes                        = ["email", "profile"]

  supported_identity_providers            = ["COGNITO"]

  callback_urls = [
    "https://grafana.${terraform.workspace}.${var.public_dns}/oauth2/callback",
    "https://tracing.${terraform.workspace}.${var.public_dns}/oauth2/callback"
  ]

  user_pool_id = "${aws_cognito_user_pool.user-pool.id}"
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain          = "domain-${terraform.workspace}"
  user_pool_id    = "${aws_cognito_user_pool.user-pool.id}"
}

output "user_pool_arn" {
    value = "${aws_cognito_user_pool.user-pool.arn}"
}

output "user_pool_client_id" {
    value = "${aws_cognito_user_pool_client.client.id}"
}

output "user_pool_client_secret" {
    value = "${aws_cognito_user_pool_client.client.client_secret}"
}

output "user_pool_domain" {
    value = "${aws_cognito_user_pool_domain.domain.domain}"
} 
