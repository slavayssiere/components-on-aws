resource "aws_eks_cluster" "demo" {
  name     = "${var.cluster-name}-${terraform.workspace}"
  role_arn = "${aws_iam_role.demo-cluster.arn}"

  enabled_cluster_log_types = ["authenticator", "api"]

  vpc_config {
    security_group_ids = ["${aws_security_group.demo-cluster.id}"]
    subnet_ids = [
      "${data.terraform_remote_state.layer-base.outputs.sn_private_a_id}",
      "${data.terraform_remote_state.layer-base.outputs.sn_private_b_id}",
      "${data.terraform_remote_state.layer-base.outputs.sn_private_c_id}"
    ]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    "aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.demo-cluster-AmazonEKSServicePolicy",
  ]

  tags = "${
    map(
     "Name", "terraform-eks-demo-${terraform.workspace}",
     "Plateform", "${terraform.workspace}"
    )
  }"
}

output "k8s_endpoint" {
  value = replace(aws_eks_cluster.demo.endpoint, "https://", "")
}

resource "aws_route53_record" "master-internal-dns" {
  zone_id = "${data.terraform_remote_state.layer-base.outputs.private_dns_zone_id}"
  name    = "k8s-master.${data.terraform_remote_state.layer-base.outputs.private_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${replace(aws_eks_cluster.demo.endpoint, "https://", "")}"]
}