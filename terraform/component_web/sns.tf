resource "aws_iam_policy" "ec2-to-sns-policy" {
  count = var.attach_sns_pub ? 1 : 0
  name        = "ec2-to-sns-policy-${terraform.workspace}"
  description = "A ec2-to-sns-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "<topic_arn>"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "web-role-ec2-to-sns-attach" {
  count = var.attach_sns_pub ? 1 : 0
  policy_arn = "${aws_iam_policy.ec2-to-sns-policy.0.arn}"
  role       = "${aws_iam_role.web-role.name}"
}
