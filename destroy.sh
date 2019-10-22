#!/bin/bash

cd terraform/layer-alb
terraform destroy -auto-approve
cd -

cd terraform/layer-eks
terraform destroy -auto-approve
cd -

cd terraform/layer-bastion
terraform destroy -auto-approve
cd -

cd terraform/layer-base
terraform destroy -auto-approve
cd -
