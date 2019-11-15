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

RUN echo "127.0.0.1	kubernetes" >> /etc/hosts && mkdir -p /app/iac

COPY iac/requirements.txt /app/iac/requirements.txt
RUN pip install -r /app/iac/requirements.txt

COPY . /app

WORKDIR /app/iac