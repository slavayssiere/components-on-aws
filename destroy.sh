#!/bin/bash

PLATEFORM_NAME=$1

cd terraform/component-eks/component-alb
terraform workspace select $PLATEFORM_NAME
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/component-eks
terraform workspace select $PLATEFORM_NAME
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/component-bastion
terraform workspace select $PLATEFORM_NAME
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/component-network
terraform workspace select $PLATEFORM_NAME
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -

cd terraform/component-base
terraform workspace select $PLATEFORM_NAME
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete $PLATEFORM_NAME
cd -
