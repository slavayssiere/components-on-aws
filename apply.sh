#!/bin/bash

cd terraform/layer-base
terraform apply
cd -

cd terraform/layer-bastion
terraform apply
cd -

cd terraform/layer-eks
terraform apply
terraform output kubeconfig > ../../tmp/.kubeconfig
terraform output config_map_aws_auth > ../../tmp/cm_auth.yaml
K8S_ENDPOINT=$(terraform output k8s_endpoint)
cd -

helm3 repo add stable https://kubernetes-charts.storage.googleapis.com/

# ssh ec2-user@bastion.aws-wescale.slavayssiere.fr -L 8443:${K8S_ENDPOINT:8}:443 &
ssh -M -S my-ctrl-socket -fnNT -L 8443:${K8S_ENDPOINT:8}:443 ec2-user@bastion.aws-wescale.slavayssiere.fr
KUBECONFIG="./tmp/.kubeconfig" kubectl apply -f ./tmp/cm_auth.yaml
KUBECONFIG="./tmp/.kubeconfig" helm3 install \
    --set rbac.enabled=true,dashboard.enabled=true,metrics.prometheus.enabled=false,metrics.serviceMonitor.enabled=true \
    --namespace kube-system \
    public-ingress stable/traefik
ssh -S my-ctrl-socket -O exit ec2-user@bastion.aws-wescale.slavayssiere.fr
#lsof -nP -i4TCP:8443 | grep LISTEN

# you can use aws eks --region eu-west-1 update-kubeconfig --name eks-test too
ssh ec2-user@bastion.aws-wescale.slavayssiere.fr aws --region eu-west-1 eks update-kubeconfig --name eks-test --role-arn arn:aws:iam::549637939820:role/system/bastion_role
