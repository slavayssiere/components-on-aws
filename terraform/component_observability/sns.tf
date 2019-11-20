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

output "sns_arn" {
  value = "${aws_cloudformation_stack.sns_topic.outputs["ARN"]}"
}