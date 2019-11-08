#!/bin/bash

rm -Rf terraform/component_base/.terraform
rm -Rf terraform/component_network/.terraform
rm -Rf terraform/component_bastion/.terraform
rm -Rf terraform/component_eks/component_alb/.terraform
rm -Rf terraform/component_eks/.terraform

cd terraform/component_base
terraform init
cd -

cd terraform/component_network
terraform init
cd -

cd terraform/component_bastion
terraform init
cd -

cd terraform/component_eks
terraform init
cd -

cd terraform/component_eks/component_alb
terraform init
cd -
