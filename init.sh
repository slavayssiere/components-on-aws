#!/bin/bash

rm -Rf terraform/component-base/.terraform
rm -Rf terraform/component-network/.terraform
rm -Rf terraform/component-bastion/.terraform
rm -Rf terraform/component-alb/.terraform
rm -Rf terraform/component-eks/.terraform

cd terraform/component-base
terraform init
cd -

cd terraform/component-network
terraform init
cd -

cd terraform/component-bastion
terraform init
cd -

cd terraform/component-alb
terraform init
cd -

cd terraform/component-eks
terraform init
cd -
