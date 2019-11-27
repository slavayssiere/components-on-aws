#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from terraform.component_web.functions import ComponentWeb

class ComponentObservability(Component):

  blocname = "component_observability"
  component_name = "observability"

  def apply(self):
    if self.blocname not in self.plateform:
      return

    if 'ips_whitelist' not in self.plateform[self.blocname]:
      self.plateform[self.blocname]['ips_whitelist'] = ["0.0.0.0/0"]

    if 'grafana' in self.plateform[self.blocname]:
      self.grafana(self.create)

    if 'tracing' in self.plateform[self.blocname]:
      self.tracing(self.create)

    if 'prometheus' in self.plateform[self.blocname]:
      self.prometheus(self.create)

    if 'alertmanager' in self.plateform[self.blocname]:
      var = {
        'bucket_component_state': self.bucket_component_state,
        'email_address': self.plateform[self.blocname]['alertmanager']['list_emails']
      }
      self.create(
        working_dir='../terraform/component_observability',
        var_component=var
      )
      sns_arn = self.output('sns_arn', working_dir='../terraform/component_observability')
      print("SNS ARN: " + sns_arn)
      sns_arn=sns_arn.split(':')[5]
      print("SNS Name: " + sns_arn)
      self.alertmanager(self.create, sns_arn)

  def destroy(self):
    if self.blocname not in self.plateform:
      return
    
    if 'ips_whitelist' not in self.plateform[self.blocname]:
      self.plateform[self.blocname]['ips_whitelist'] = ["0.0.0.0/0"]

    if 'grafana' in self.plateform[self.blocname]:
      print("destroy grafana")
      self.grafana(self.delete)

    if 'tracing' in self.plateform[self.blocname]:
      print("destroy tracing")
      self.tracing(self.delete)

    if 'prometheus' in self.plateform[self.blocname]:
      print("destroy prometheus")
      self.prometheus(self.delete)

    if 'alertmanager' in self.plateform[self.blocname]:
      print("destroy alertmanager")
      var = {
        'bucket_component_state': self.bucket_component_state,
        'email_address': self.plateform[self.blocname]['alertmanager']['list_emails']
      }
      self.delete(
        working_dir='../terraform/component_observability',
        var_component=var
      )
      self.alertmanager(self.delete, 'sns-arn')

  def grafana(self, func):
    ami_account = self.plateform['account']
    if 'ami-account' in self.plateform[self.blocname]:
      ami_account = self.plateform[self.blocname]['ami-account']

    grafana = ComponentWeb(self.plateform)
    web={
      'name': 'grafana',
      'ami-name': 'grafana-*',
      'ami-account': ami_account,
      'port': '3000',
      'health-check': '/api/health',
      'health-check-port': '3000',
      'attach_cw_ro': True,
      'efs-enable': False,
      'node-count': 1,
      'min-node-count': 1,
      'max-node-count': 1,
      'ips_whitelist': self.plateform[self.blocname]['ips_whitelist'],
      'enable_cognito': True,
      'user-data': '''
        #!/bin/bash -x
        exec > /tmp/userdata-grafana.log 2>&1
        grafana-cli admin reset-admin-password {password}
      '''.format(password='new-password')
    }
    grafana.compute_var(web, func)

  def tracing(self, func):
    ami_account = self.plateform['account']
    if 'ami-account' in self.plateform[self.blocname]:
      ami_account = self.plateform[self.blocname]['ami-account']

    tracing = ComponentWeb(self.plateform)
    web={
      'name': 'tracing',
      'ami-name': 'jaeger-*',
      'ami-account': ami_account,
      'port': '16686',
      'health-check': '/',
      'health-check-port': '16687',
      'attach_cw_ro': False,
      'efs-enable': False,
      'node-count': 1,
      'min-node-count': 1,
      'max-node-count': 1,
      'ips_whitelist': self.plateform[self.blocname]['ips_whitelist'],
      'enable_cognito': True
    }
    tracing.compute_var(web, func)


  def prometheus(self, func):
    ami_account = self.plateform['account']
    if 'ami-account' in self.plateform[self.blocname]:
      ami_account = self.plateform[self.blocname]['ami-account']

    prometheus = ComponentWeb(self.plateform)
    web={
      'name': 'prometheus',
      'ami-name': 'prometheus-*',
      'ami-account': ami_account,
      'port': '9090',
      'health-check': '/-/ready',
      'attach_cw_ro': False,
      'attach_ec2_ro': True,
      'efs-enable': False,
      'node-count': 1,
      'min-node-count': 1,
      'max-node-count': 1,
      'ips_whitelist': self.plateform[self.blocname]['ips_whitelist'],
      'enable_cognito': False,
      'enable_private_alb': True,
      'enable_public_alb': True
    }
    prometheus.compute_var(web, func)


  def alertmanager(self, func, sns_arn):
    ami_account = self.plateform['account']
    if 'ami-account' in self.plateform[self.blocname]:
      ami_account = self.plateform[self.blocname]['ami-account']

    alertmanager = ComponentWeb(self.plateform)
    web={
      'name': 'alertmanager',
      'ami-name': 'alertmanager-*',
      'ami-account': ami_account,
      'port': '9093',
      'health-check': '/-/ready',
      'attach_sns_pub': True,
      'efs-enable': False,
      'node-count': 1,
      'min-node-count': 1,
      'max-node-count': 1,
      'ips_whitelist': self.plateform[self.blocname]['ips_whitelist'],
      'enable_cognito': False,
      'enable_private_alb': True,
      'enable_public_alb': True,
      'user-data': '''
        #!/bin/bash -x
        exec > /tmp/userdata-alertmanager.log 2>&1
        sudo sed -i.bak 's/alertmanager-sns-to-email/{sns_arn}/g' /etc/alertmanager/alertmanager.yml
        systemctl restart alertmanager.service
      '''.format(sns_arn=sns_arn.replace('\n', ''))
    }
    alertmanager.compute_var(web, func)

# sudo journalctl -o verbose --unit=alertmanager.service

        # 'user-data': '''
        #   echo "[auth.generic_oauth]" >> /etc/grafana/grafana.ini
        #   echo "  enabled = true" >> /etc/grafana/grafana.ini
        #   echo "  client_id = {client_id}" >> /etc/grafana/grafana.ini
        #   echo "  client_secret = {client_secret}" >> /etc/grafana/grafana.ini
        #   echo "  scopes = openid" >> /etc/grafana/grafana.ini
        #   echo "  auth_url = https://grafana.{plateform_url}/oauth2/authorize" >> /etc/grafana/grafana.ini
        #   echo "  token_url = https://grafana.{plateform_url}/oauth2/token" >> /etc/grafana/grafana.ini
        #   echo "  api_url = https://grafana.{plateform_url}/oauth2/userInfo" >> /etc/grafana/grafana.ini
        #   echo "  allowed_domains = lzdev.cloud" >> /etc/grafana/grafana.ini
        #   echo "  allow_sign_up = true" >> /etc/grafana/grafana.ini
        #   '''.format(client_id='123', client_secret='123',plateform_url=plateform['name']+"."+plateform['public-dns'])