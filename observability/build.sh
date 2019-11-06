#!/bin/bash

# wget https://releases.hashicorp.com/packer/1.4.5/packer_1.4.5_darwin_amd64.zip

APP=$1

packer validate $APP/packer.json
packer build $APP/packer.json