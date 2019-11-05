#!/bin/bash

PLATEFORM_NAME=$1
NETWORK_TYPE=$2
ACCOUNT=$3

WORKDIR=$PWD

cd ../terraform/component-eks
terraform output kubeconfig > $WORKDIR/tmp/.kubeconfig_$PLATEFORM_NAME
terraform output config_map_aws_auth > $WORKDIR/tmp/cm_auth_$PLATEFORM_NAME.yaml
cd -

ssh -M -S my-ctrl-socket -fnNT -L 8443:k8s-master.slavayssiere.wescale:443 ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr

export KUBECONFIG="$WORKDIR/tmp/.kubeconfig_$PLATEFORM_NAME"

# creation des identitées IAM dans EKS
kubectl apply -f $WORKDIR/tmp/cm_auth_$PLATEFORM_NAME.yaml

ssh -S my-ctrl-socket -O exit ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr
#lsof -nP -i4TCP:8443 | grep LISTEN

# you can use aws eks --region eu-west-1 update-kubeconfig --name eks-test too
ssh ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr aws --region eu-west-1 eks update-kubeconfig --name eks-test-$PLATEFORM_NAME --role-arn arn:aws:iam::$ACCOUNT:role/bastion_role_$PLATEFORM_NAME

scp -r $WORKDIR/../terraform/component-eks/mon-network ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr:
scp -r $WORKDIR/../terraform/component-eks/helm_values ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr:
scp -r $WORKDIR/../terraform/component-eks/ingress ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr:
scp $WORKDIR/../terraform/component-eks/eks-on-bastion.sh ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr:

ssh ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr ./eks-on-bastion.sh
