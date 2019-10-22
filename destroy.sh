#!/bin/bash

PLATEFORM_NAME=$1

cd terraform/layer-alb
terraform workspace select $PLATEFORM_NAME
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/layer-eks
terraform workspace select $PLATEFORM_NAME
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/layer-bastion
terraform workspace select $PLATEFORM_NAME
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/layer-base
terraform workspace select $PLATEFORM_NAME
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -
