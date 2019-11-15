#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from terraform.component_web.functions import apply as apply_web
from terraform.component_web.functions import destroy as destroy_web

def apply(bucket_component_state, plateform):
  bastion_enable = False
  if 'component_bastion' in plateform:
    bastion_enable = True

  if 'ips_whitelist' not in plateform['component_observability']:
    plateform['component_observability']['ips_whitelist'] = ["0.0.0.0/0"]
         
  if 'grafana' in plateform['component_observability']:
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
        'ips_whitelist': plateform['component_observability']['ips_whitelist'],
        'enable_cognito': True
    }

    apply_web(bucket_component_state=bucket_component_state, web=web, plateform_name=plateform['name'], account=plateform['account'], bastion_enable=bastion_enable)
  if 'tracing' in plateform['component_observability']:
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
        'ips_whitelist': plateform['component_observability']['ips_whitelist'],
        'enable_cognito': True
    }
    apply_web(bucket_component_state=bucket_component_state, web=web, plateform_name=plateform['name'], account=plateform['account'], bastion_enable=bastion_enable)

def destroy(bucket_component_state, plateform):         
  if 'grafana' in plateform['component_observability']:
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
        'ips_whitelist': ["0.0.0.0/0"],
        'enable_cognito': True
    }
    destroy_web(bucket_component_state=bucket_component_state, web=web, plateform_name=plateform['name'], account=plateform['account'])
  if 'tracing' in plateform['component_observability']:
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
        'ips_whitelist': ["0.0.0.0/0"],
        'enable_cognito': True
    }
    destroy_web(bucket_component_state=bucket_component_state, web=web, plateform_name=plateform['name'], account=plateform['account'])


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