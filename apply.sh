#!/bin/bash

PLATEFORM_NAME=$1
NETWORK_TYPE=$2

ACCOUNT="549637939820"

if [ -z "$NETWORK_TYPE" ]
then
    NETWORK_TYPE="calico"
fi

if [ -z "$PLATEFORM_NAME" ]
then
    PLATEFORM_NAME="calico"
fi

cd terraform/component-base
terraform workspace new $PLATEFORM_NAME
terraform apply -var "account_id=$ACCOUNT" -auto-approve
cd -

cd terraform/component-eks
./apply.sh
cd -

cd terraform/component-bastion
terraform workspace new $PLATEFORM_NAME
terraform apply -auto-approve
cd -
