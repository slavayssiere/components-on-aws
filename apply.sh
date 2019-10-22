#!/bin/bash

NETWORK_TYPE="calico"
PLATEFORM_NAME="calico"

cd terraform/layer-base
terraform workspace new $PLATEFORM_NAME
terraform apply
cd -

cd terraform/layer-bastion
terraform workspace new $PLATEFORM_NAME
terraform apply
cd -

cd terraform/layer-eks
terraform workspace new $PLATEFORM_NAME
terraform apply
terraform output kubeconfig > ../../tmp/.kubeconfig
terraform output config_map_aws_auth > ../../tmp/cm_auth.yaml
K8S_ENDPOINT=$(terraform output k8s_endpoint)
cd -

helm3 repo add stable https://kubernetes-charts.storage.googleapis.com/

# ssh ec2-user@bastion.aws-wescale.slavayssiere.fr -L 8443:${K8S_ENDPOINT:8}:443 &
ssh -M -S my-ctrl-socket -fnNT -L 8443:k8s-master.slavayssiere.wescale:443 ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr
KUBECONFIG="./tmp/.kubeconfig" kubectl apply -f ./tmp/cm_auth.yaml
KUBECONFIG="./tmp/.kubeconfig" helm3 install \
    --set rbac.enabled=true,dashboard.enabled=true,metrics.prometheus.enabled=false,metrics.serviceMonitor.enabled=true,serviceType=NodePort,service.nodePorts.http=32001,kubernetes.ingressClass=public-ingress \
    --namespace kube-system \
    public-ingress stable/traefik
KUBECONFIG="./tmp/.kubeconfig" helm3 install \
    --set rbac.enabled=true,dashboard.enabled=true,metrics.prometheus.enabled=false,metrics.serviceMonitor.enabled=true,serviceType=NodePort,service.nodePorts.http=32002,kubernetes.ingressClass=private-ingress \
    --namespace kube-system \
    private-ingress stable/traefik

if [ "$NETWORK_TYPE" == "calico" ]; then
    echo "Installation de calico"
    KUBECONFIG="./tmp/.kubeconfig" kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.5/calico.yaml
else
    echo "Strings are not equal"
fi

ssh -S my-ctrl-socket -O exit ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr
#lsof -nP -i4TCP:8443 | grep LISTEN

cd terraform/layer-alb
terraform workspace new $PLATEFORM_NAME
terraform apply
cd -

# you can use aws eks --region eu-west-1 update-kubeconfig --name eks-test too
ssh ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr aws --region eu-west-1 eks update-kubeconfig --name eks-test-$PLATEFORM_NAME --role-arn arn:aws:iam::549637939820:role/system/bastion_role_$PLATEFORM_NAME
