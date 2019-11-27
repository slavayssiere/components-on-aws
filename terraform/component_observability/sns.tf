data "template_file" "cloudformation_sns_stack" {
  template = "${file("${path.module}/email-sns-stack.json.tpl")}"
  vars = {
    display_name  = "alertmanager-sns-${terraform.workspace}"
    subscriptions = "${join("," , formatlist("{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\"  }", var.email_address, "email"))}"
  }
}

resource "aws_cloudformation_stack" "sns_topic" {
  name          = "alertmanager-sns-${terraform.workspace}"
  template_body = "${data.template_file.cloudformation_sns_stack.rendered}"
  tags = "${merge(
    map("Name", "alertmanager-sns-${terraform.workspace}")
  )}"
}

// resource "aws_sns_topic" "billing-topic" {
//   name = "billing-topic-${terraform.workspace}"
// }

// resource "aws_ses_identity_notification_topic" "test" {
//   topic_arn                = "${aws_sns_topic.billing-topic.arn}"
//   notification_type        = "Bounce"
//   identity                 = "${aws_ses_domain_identity.public-ses.domain}"
//   include_original_headers = true
// }


output "sns_arn" {
  value = "${aws_cloudformation_stack.sns_topic.outputs["ARN"]}"
}