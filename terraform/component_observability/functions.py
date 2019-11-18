#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from terraform.component_web.functions import ComponentWeb

class ComponentObservability(Component):

  def apply(self):
    if 'ips_whitelist' not in self.plateform['component_observability']:
      self.plateform['component_observability']['ips_whitelist'] = ["0.0.0.0/0"]

    if 'grafana' in self.plateform['component_observability']:
      self.grafana(self.create)

    if 'tracing' in self.plateform['component_observability']:
      self.tracing(self.create)

  def destroy(self):
    if 'ips_whitelist' not in self.plateform['component_observability']:
      self.plateform['component_observability']['ips_whitelist'] = ["0.0.0.0/0"]

    if 'grafana' in self.plateform['component_observability']:
      self.grafana(self.delete)

    if 'tracing' in self.plateform['component_observability']:
      self.tracing(self.delete)

  def grafana(self, func):
    grafana = ComponentWeb(self.plateform)
    web={
      'name': 'grafana',
      'ami-name': 'grafana-*',
      'port': '3000',
      'health-check': '/api/health',
      'health-check-port': '3000',
      'attach_cw_ro': True,
      'efs-enable': False,
      'node-count': 1,
      'min-node-count': 1,
      'max-node-count': 1,
      'ips_whitelist': self.plateform['component_observability']['ips_whitelist'],
      'enable_cognito': True
    }
    grafana.compute_var(web, func)

  def tracing(self, func):
    tracing = ComponentWeb(self.plateform)
    web={
      'name': 'tracing',
      'ami-name': 'jaeger-*',
      'port': '16686',
      'health-check': '/',
      'health-check-port': '16687',
      'attach_cw_ro': False,
      'efs-enable': False,
      'node-count': 1,
      'min-node-count': 1,
      'max-node-count': 1,
      'ips_whitelist': self.plateform['component_observability']['ips_whitelist'],
      'enable_cognito': True
    }
    tracing.compute_var(web, func)


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