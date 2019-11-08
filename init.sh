#!/bin/bash

# backend_bucket="wescale-slavayssiere-terraform"
backend_bucket="accor-slavayssiere-terraform"

echo "rm all .terraform directory"
rm -Rf terraform/component_base/.terraform
rm -Rf terraform/component_bastion/.terraform
rm -Rf terraform/component_network/.terraform
rm -Rf terraform/component_eks/component-alb/.terraform
rm -Rf terraform/component_eks/.terraform
rm -Rf terraform/component_rds/.terraform
rm -Rf terraform/component_web/.terraform

echo "component_base"
cd terraform/component_base
terraform init \
    -backend-config="bucket=$backend_bucket"
cd -

echo "component_bastion"
cd terraform/component_bastion
terraform init \
    -backend-config="bucket=$backend_bucket"
cd -

echo "component_eks"
cd terraform/component_eks
terraform init \
    -backend-config="bucket=$backend_bucket"
cd -

echo "component_eks/component_alb"
cd terraform/component_eks/component-alb
terraform init \
    -backend-config="bucket=$backend_bucket"
cd -

echo "component_network"
cd terraform/component_network
terraform init \
    -backend-config="bucket=$backend_bucket"
cd -

echo "component_rds"
cd terraform/component_rds
terraform init \
    -backend-config="bucket=$backend_bucket"
cd -

echo "component_web"
cd terraform/component_web
terraform init \
    -backend-config="bucket=$backend_bucket"
cd -
