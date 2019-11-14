resource "aws_iam_policy" "cw-grafana-policy" {
  count = var.attach_cw_ro ? 1 : 0
  name        = "cw-grafana-policy-${terraform.workspace}"
  description = "A cw-grafana-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowReadingMetricsFromCloudWatch",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:DescribeAlarmsForMetric",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:GetMetricData"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowReadingTagsInstancesRegionsFromEC2",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ec2:DescribeInstances",
                "ec2:DescribeRegions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowReadingResourcesForTags",
            "Effect" : "Allow",
            "Action" : "tag:GetResources",
            "Resource" : "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "web-role-cw-attach" {
  count = var.attach_cw_ro ? 1 : 0
  policy_arn = "${aws_iam_policy.cw-grafana-policy.0.arn}"
  role       = "${aws_iam_role.web-role.name}"
}
