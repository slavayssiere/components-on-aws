resource "aws_eks_cluster" "demo" {
  name     = "${var.cluster-name}"
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
}

output "k8s_endpoint" {
  value = aws_eks_cluster.demo.endpoint
}

resource "aws_route53_record" "master-internal-dns" {
  zone_id = "${data.terraform_remote_state.layer-base.outputs.private_dns_zone_id}"
  name    = "k8s-master.${data.terraform_remote_state.layer-base.outputs.private_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_eks_cluster.demo.endpoint}"]
}