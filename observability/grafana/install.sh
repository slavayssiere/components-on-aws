#!/bin/bash

yum install -y https://dl.grafana.com/oss/release/grafana-6.4.3-1.x86_64.rpm
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service
