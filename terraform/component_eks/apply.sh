#!/bin/bash

PLATEFORM_NAME=$1
NETWORK_TYPE=$2
ACCOUNT=$3
DNS_PUBLIC=$4
DNS_PRIVATE=$5

WORKDIR=$PWD

cd ../terraform/component_eks
echo $PWD
terraform output kubeconfig > $WORKDIR/tmp/.kubeconfig_$PLATEFORM_NAME
terraform output config_map_aws_auth > $WORKDIR/tmp/cm_auth_$PLATEFORM_NAME.yaml
cd -

ssh -M -S my-ctrl-socket -fnNT -L 8443:k8s-master.$DNS_PRIVATE:443 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@bastion.$PLATEFORM_NAME.$DNS_PUBLIC

export KUBECONFIG="$WORKDIR/tmp/.kubeconfig_$PLATEFORM_NAME"

# creation des identitées IAM dans EKS
kubectl apply -f $WORKDIR/tmp/cm_auth_$PLATEFORM_NAME.yaml

ssh -S my-ctrl-socket -O exit ec2-user@bastion.$PLATEFORM_NAME.$DNS_PUBLIC
#lsof -nP -i4TCP:8443 | grep LISTEN

# you can use aws eks --region eu-west-1 update-kubeconfig --name eks-test too
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@bastion.$PLATEFORM_NAME.$DNS_PUBLIC aws --region eu-west-1 eks update-kubeconfig --name eks-test-$PLATEFORM_NAME --role-arn arn:aws:iam::$ACCOUNT:role/bastion_role_$PLATEFORM_NAME

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $WORKDIR/../terraform/component_eks/mon-network ec2-user@bastion.$PLATEFORM_NAME.$DNS_PUBLIC:
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $WORKDIR/../terraform/component_eks/helm_values ec2-user@bastion.$PLATEFORM_NAME.$DNS_PUBLIC:
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $WORKDIR/../terraform/component_eks/ingress ec2-user@bastion.$PLATEFORM_NAME.$DNS_PUBLIC:
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $WORKDIR/../terraform/component_eks/eks-on-bastion.sh ec2-user@bastion.$PLATEFORM_NAME.$DNS_PUBLIC:
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $WORKDIR/../terraform/component_eks/templates/node-exporter-nodeport.yaml ec2-user@bastion.$PLATEFORM_NAME.$DNS_PUBLIC:

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@bastion.$PLATEFORM_NAME.$DNS_PUBLIC ./eks-on-bastion.sh $PLATEFORM_NAME $NETWORK_TYPE $DNS_PUBLIC
