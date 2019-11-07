#!/bin/bash

# wget https://releases.hashicorp.com/packer/1.4.5/packer_1.4.5_darwin_amd64.zip

APP=$1

if test -f "variables.json"; then
    echo "Parameter file: $APP/variables.json"
    packer validate -var-file=$APP/variables.json $APP/packer.json 
    packer build -var-file=$APP/variables.json $APP/packer.json
else
    echo "No parameter file"
    packer validate $APP/packer.json 
    packer build $APP/packer.json
fi
