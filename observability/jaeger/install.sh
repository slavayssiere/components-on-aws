#!/bin/bash

wget -O jaeger.tar.gz https://github.com/jaegertracing/jaeger/releases/download/v1.14.0/jaeger-1.14.0-linux-amd64.tar.gz
tar -xf jaeger.tar.gz

chmod +x jaeger*/jaeger-*

sudo mv jaeger*/jaeger-* /usr/local/bin/

sudo mv /tmp/jaeger-collector.service /etc/systemd/system/jaeger-collector.service
sudo mv /tmp/jaeger-query.service /etc/systemd/system/jaeger-query.service

systemctl start jaeger-collector
systemctl start jaeger-query

systemctl enable jaeger-collector
systemctl enable jaeger-query
