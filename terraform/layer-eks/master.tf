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

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demo.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
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