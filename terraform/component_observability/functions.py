#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from terraform.component_web.functions import apply as apply_web

def apply(bucket_component_state, plateform):            
  if 'grafana' in plateform['component_observability']:
    web={
        'name': 'grafana',
        'ami-name': 'grafana-*',
        'port': '3000',
        'health-check': '/api/health',
        'health-check-port': '3000'
    }
    apply_web(bucket_component_state=bucket_component_state, web=web, plateform_name=plateform['name'], account=plateform['account'])
  if 'tracing' in plateform['component_observability']:
    web={
        'name': 'tracing',
        'ami-name': 'jaeger-*',
        'port': '16686',
        'health-check': '/',
        'health-check-port': '16687'
    }
    apply_web(bucket_component_state=bucket_component_state, web=web, plateform_name=plateform['name'], account=plateform['account'])

