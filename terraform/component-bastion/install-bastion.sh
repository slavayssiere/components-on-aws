#!/bin/bash

sudo chmod a+w /etc/environment  >> /dev/null 2>&1
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment

#install kubectl
wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# install aws-iam-authenticator
wget -O aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.4.0/aws-iam-authenticator_0.4.0_linux_amd64
chmod +x ./aws-iam-authenticator
sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

## update aws-cli
yum -y install awscli

wget -O helm.tar.gz https://get.helm.sh/helm-v3.0.0-rc.2-linux-amd64.tar.gz
tar -xf helm.tar.gz
chmod +x linux-amd64/helm
sudo mv linux-amd64/helm /usr/local/bin/helm

wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x jq-linux64
sudo mv jq-linux64 /usr/local/bin/jq


# helm configure
aws configure set region eu-west-1
sudo yum install -y git >> /dev/null 2>&1
helm repo add stable https://kubernetes-charts.storage.googleapis.com/


#install calicoctl
curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.3.0/calicoctl  >> /dev/null 2>&1
chmod +x calicoctl >> /dev/null 2>&1
sudo mv calicoctl /usr/local/bin/calicoctl >> /dev/null 2>&1

echo "export DATASTORE_TYPE=kubernetes" >> /home/ec2-user/.bashrc
echo "export KUBECONFIG=~/.kube/config" >> /home/ec2-user/.bashrc

# configure ssh
echo "Host *.slavayssiere.wescale" >> /etc/ssh/ssh_config
echo "  StrictHostKeyChecking no" >> /etc/ssh/ssh_config

sudo systemctl restart sshd
sudo chmod a-w /etc/ssh/ssh_config
