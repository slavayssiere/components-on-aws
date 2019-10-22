#!/bin/bash

PLATEFORM_NAME="calico"

cd terraform/layer-alb
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/layer-eks
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/layer-bastion
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/layer-base
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -
