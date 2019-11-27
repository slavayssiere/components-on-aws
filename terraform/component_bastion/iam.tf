resource "aws_iam_role" "bastion_role" {
  name               = "bastion_role_${terraform.workspace}"
  assume_role_policy = "${data.aws_iam_policy_document.bastion-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "S3-attach" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy" "eks_describe_access" {
  count = var.enable_eks ? 1 : 0
  name        = "eks_describe_access_${terraform.workspace}"
  description = "A eks_describe_access policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "EKS-attach" {
  count = var.enable_eks ? 1 : 0
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "${aws_iam_policy.eks_describe_access.arn}"
}