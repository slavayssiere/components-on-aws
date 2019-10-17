#!/bin/bash


cd terraform/layer-eks
terraform destroy
cd -

cd terraform/layer-bastion
terraform destroy
cd -

# cd terraform/layer-base
# terraform destroy
# cd -
