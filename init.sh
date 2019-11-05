#!/bin/bash

rm -Rf component-base/.terraform
rm -Rf component-network/.terraform
rm -Rf component-bastion/.terraform
rm -Rf component-alb/.terraform
rm -Rf component-eks/.terraform

cd component-base
terraform init
cd -

cd component-network
terraform init
cd -

cd component-bastion
terraform init
cd -

cd component-alb
terraform init
cd -

cd component-eks
terraform init
cd -
