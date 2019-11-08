#!/bin/bash

NAME="test"

helm repo add stable https://kubernetes-charts.storage.googleapis.com/

kubectl create ns jenkins-$NAME
helm3 install \
    --namespace jenkins-$NAME \
    --values ./terraform/component_eks/helm_values/jenkins.yaml \
    --set master.jenkinsUriPrefix="/jenkins-$NAME" \
    --set master.ingress.path="/jenkins-$NAME" \
    --set master.ingress.hostname="public.calico.aws-wescale.slavayssiere.fr" \
    jenkins-$NAME stable/jenkins