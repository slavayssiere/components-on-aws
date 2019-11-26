#!/bin/bash

PLATEFORM_NAME=$1
NETWORK_TYPE=$2
DNS_PUBLIC=$3

echo "wait for node to register"
sleep 30

# création des CRD de prometheus-operator
kubectl create ns observability

tar -xf prometheus-operator-8.2.4.tar

# installation du prometheus operator
helm upgrade \
    -i \
    --namespace observability \
    --values ./helm_values/prometheus-operator.yaml \
    --wait \
    prometheus-operator ./prometheus-operator

kubectl apply -f ./mon-network/prometheus.yaml
kubectl apply -f ./mon-network/grafana-datasource.yaml

# on installe le CNI
echo "We install the $NETWORK_TYPE CNI"
if [ "$NETWORK_TYPE" == "calico" ]; then
    echo "Installation de calico"
    kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.5/calico.yaml
    kubectl apply -f ./mon-network/calico-sm.yaml
else
    echo "Installation de cilium"
    if [ ! -d "cilium-v1.6.3" ]; then
        wget -O cilium.tar.gz http://releases.cilium.io/v1.6.3/v1.6.3.tar.gz
        tar -xf cilium.tar.gz
        rm -f cilium.tar.gz
    fi

    helm upgrade \
        -i \
        --namespace kube-system \
        --values ./helm_values/cilium.yaml \
        --wait \
        cilium cilium-v1.6.3/install/kubernetes/cilium

    # la création des SM dans cilium est désactivé
    kubectl apply -f ./mon-network/agent-sm.yaml
    kubectl apply -f ./mon-network/operator-sm.yaml
    kubectl apply -f ./mon-network/cilium-dashboard.yaml
fi

helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update


# installation des IngressController
helm upgrade \
    -i \
    --namespace kube-system \
    --values ./helm_values/traefik-public.yaml \
    --set dashboard.domain=private.$PLATEFORM_NAME.$DNS_PUBLIC \
    --wait \
    public-ingress stable/traefik

helm upgrade \
    -i \
    --namespace kube-system \
    --values ./helm_values/traefik-private.yaml \
    --set dashboard.domain=private.$PLATEFORM_NAME.$DNS_PUBLIC \
    --wait \
    private-ingress stable/traefik


# add ingress
kubectl apply -f ./ingress/traefik-private.yaml
kubectl apply -f ./ingress/traefik-public.yaml
kubectl apply -f ./ingress/grafana.yaml
kubectl apply -f ./ingress/prometheus-k8s.yaml
kubectl apply -f ./templates/node-exporter-nodeport.yaml
