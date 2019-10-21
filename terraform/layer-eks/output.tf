output "public-target-group" {
    value = aws_lb_target_group.eks-nodes-public-ingress.arn
}

output "private-target-group" {
    value = aws_lb_target_group.eks-nodes-private-ingress.arn
}