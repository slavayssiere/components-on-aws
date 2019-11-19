resource "aws_iam_policy" "ec2-prometheus-policy" {
  count = var.attach_ec2_ro ? 1 : 0
  name        = "ec2-prometheus-policy-${terraform.workspace}"
  description = "A ec2-prometheus-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:Describe*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "web-role-ec2-prometheus-attach" {
  count = var.attach_ec2_ro ? 1 : 0
  policy_arn = "${aws_iam_policy.ec2-prometheus-policy.0.arn}"
  role       = "${aws_iam_role.web-role.name}"
}
