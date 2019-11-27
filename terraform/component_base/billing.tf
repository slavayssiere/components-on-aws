resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name                = "billing-alarm-${lower(var.currency)}-${terraform.workspace}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "EstimatedCharges"
  namespace                 = "AWS/Billing"
  period                    = "28800"
  statistic                 = "Maximum"
  threshold                 = "${var.monthly_billing_threshold}"
  alarm_actions             = ["${aws_sns_topic.billing-topic.arn}"]

  dimensions = {
      Currency = var.currency
  }
}

# TODO: implement plateform dimension


resource "aws_sns_topic" "billing-topic" {
  name = "billing-topic-${terraform.workspace}"
}

resource "aws_ses_identity_notification_topic" "test" {
  topic_arn                = "${aws_sns_topic.billing-topic.arn}"
  notification_type        = "Bounce"
  identity                 = "${aws_ses_domain_identity.public-ses.domain}"
  include_original_headers = true
}

// data "template_file" "cloudformation_sns_stack" {
//   template = "${file("${path.module}/email-sns-stack.json.tpl")}"
//   vars = {
//     display_name  = "billing-alert-${terraform.workspace}"
//     subscriptions = "${join("," , formatlist("{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\"  }", var.email_address, "email"))}"
//   }
// }

// resource "aws_cloudformation_stack" "sns_topic" {
//   name          = "billing-alert-${terraform.workspace}"
//   template_body = "${data.template_file.cloudformation_sns_stack.rendered}"
//   tags = "${merge(
//     map("Name", "billing-alert-${terraform.workspace}")
//   )}"
// }