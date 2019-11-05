output "public-target-group" {
  value = aws_lb_target_group.eks-nodes-public-ingress.arn
}

output "private-target-group" {
  value = aws_lb_target_group.eks-nodes-private-ingress.arn
}

output "nodes_sg" {
  value = aws_security_group.demo-node.id
}

output "allow_https_id" {
  value = aws_security_group.allow_https.id
}
