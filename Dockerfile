FROM python:3-alpine

RUN mkdir -p /app && \
  apk add --update git bash curl unzip zip openssl make openssh-client

ENV TERRAFORM_VERSION="0.12.3"

RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin \
  && rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin/kubectl

RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator \
  && chmod +x ./aws-iam-authenticator \
  && mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf
RUN echo "127.0.0.1	kubernetes" >> /etc/hosts && mkdir -p /app/iac

COPY iac/requirements.txt /app/iac/requirements.txt
RUN pip install -r /app/iac/requirements.txt

COPY . /app

WORKDIR /app/iac
