resource "aws_iam_role" "bastion_role" {
  name               = "bastion_role"
  path               = "/system/"
  assume_role_policy = "${data.aws_iam_policy_document.bastion-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "EC2-attach" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "S3-attach" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy" "eks_full_access" {
  name        = "eks_full_access"
  description = "A EKSFullAccess policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

// # define a role trust policy that opens the role to users in your account (limited by IAM policy)
// POLICY=$(echo -n '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':root"},"Action":"sts:AssumeRole","Condition":{}}]}')

// # create a role named KubernetesAdmin (will print the new role's ARN)
// aws iam create-role \
//   --role-name KubernetesAdmin \
//   --description "Kubernetes administrator role (for AWS IAM Authenticator for Kubernetes)." \
//   --assume-role-policy-document "$POLICY" \
//   --output text \
//   --query 'Role.Arn'

resource "aws_iam_role_policy_attachment" "EKS-attach" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "${aws_iam_policy.eks_full_access.arn}"
}

resource "aws_iam_role_policy_attachment" "STS-assume-role-attach" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "arn:aws:iam::549637939820:policy/STSAssumeRoleOnly"
}