#!/bin/bash

NETWORK_TYPE="calico"
PLATEFORM_NAME="calico"

cd terraform/layer-base
terraform workspace new $PLATEFORM_NAME
terraform apply -auto-approve
cd -

cd terraform/layer-bastion
terraform workspace new $PLATEFORM_NAME
terraform apply -auto-approve
cd -

cd terraform/layer-eks
terraform workspace new $PLATEFORM_NAME
terraform apply -auto-approve
terraform output kubeconfig > ../../tmp/.kubeconfig_$PLATEFORM_NAME
terraform output config_map_aws_auth > ../../tmp/cm_auth_$PLATEFORM_NAME.yaml
K8S_ENDPOINT=$(terraform output k8s_endpoint)
cd -

helm3 repo add stable https://kubernetes-charts.storage.googleapis.com/

# ssh ec2-user@bastion.aws-wescale.slavayssiere.fr -L 8443:${K8S_ENDPOINT:8}:443 &
ssh -M -S my-ctrl-socket -fnNT -L 8443:k8s-master.slavayssiere.wescale:443 ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr

export KUBECONFIG="./tmp/.kubeconfig_$PLATEFORM_NAME"

# creation des identitées IAM dans EKS
kubectl apply -f ./tmp/cm_auth_$PLATEFORM_NAME.yaml

echo "wait for node to register"
sleep 30

# création des CRD de prometheus-operator
kubectl create ns observability
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/alertmanager.crd.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheus.crd.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheusrule.crd.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/servicemonitor.crd.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/podmonitor.crd.yaml

until kubectl get crd servicemonitors.monitoring.coreos.com
do
  echo "wait for servicemonitors"
done

kubectl apply -f ./mon-cilium/prometheus.yaml
kubectl apply -f ./mon-cilium/grafana-datasource.yaml

# on installe le CNI
if [ "$NETWORK_TYPE" == "calico" ]; then
    echo "Installation de calico"
    kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.5/calico.yaml
    kubectl apply -f ./mon-cilium/calico-sm.yaml

else
    echo "Installation de cilium"
    if [ ! -d "cilium-v1.6.3" ]; then
        wget -O cilium.tar.gz http://releases.cilium.io/v1.6.3/v1.6.3.tar.gz
        tar -xf cilium.tar.gz
        rm -f cilium.tar.gz
    fi

    helm3 install \
        --namespace kube-system \
        --values ./helm_values/cilium.yaml \
        cilium cilium-v1.6.3/install/kubernetes/cilium

    # la création des SM dans cilium est désactivé
    kubectl apply -f ./mon-cilium/agent-sm.yaml
    kubectl apply -f ./mon-cilium/operator-sm.yaml
    kubectl apply -f ./mon-cilium/cilium-dashboard.yaml
fi

# installation du prometheus operator
helm3 install \
    --namespace observability \
    --values ./helm_values/prometheus-operator.yaml \
    --version 6.21.0 \
    --wait \
    prometheus-operator stable/prometheus-operator

# installation des IngressController
helm3 install \
    --namespace kube-system \
    --values ./helm_values/traefik-public.yaml \
    --set dashboard.domain=private.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr \
    --wait \
    public-ingress stable/traefik
helm3 install \
    --namespace kube-system \
    --values ./helm_values/traefik-private.yaml \
    --set dashboard.domain=private.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr \
    --wait \
    private-ingress stable/traefik

# add ingress
kubectl apply -f ./ingress/traefik-private.yaml
kubectl apply -f ./ingress/traefik-public.yaml
kubectl apply -f ./ingress/grafana.yaml
kubectl apply -f ./ingress/prometheus-k8s.yaml

# GRAFANA_ADMIN_PASSWORD=$(kubectl get secret prometheus-operator-grafana -n observability -o jsonpath="{.data.admin-password}" | base64 -D)

ssh -S my-ctrl-socket -O exit ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr
#lsof -nP -i4TCP:8443 | grep LISTEN

cd terraform/layer-alb
terraform workspace new $PLATEFORM_NAME
terraform apply -auto-approve
cd -

# you can use aws eks --region eu-west-1 update-kubeconfig --name eks-test too
ssh ec2-user@bastion.$PLATEFORM_NAME.aws-wescale.slavayssiere.fr aws --region eu-west-1 eks update-kubeconfig --name eks-test-$PLATEFORM_NAME --role-arn arn:aws:iam::549637939820:role/bastion_role_$PLATEFORM_NAME
