#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component

def apply(plateform):            
  if 'grafana' in plateform['component_observability']:
    grafana_plateform_name=plateform['name']+"-grafana"
    var_web={
        'workspace-network': plateform['name'],
        'dns-name': 'grafana',
        'ami': 'ami-0cd35dee04b2dc36c',
        'port': '3000',
        'health_check': '/api/health',
        'health_check_port': '3000'
    }
    create_component(working_dir='../terraform/component_web', plateform_name=grafana_plateform_name, var_component=var_web)
  if 'tracing' in plateform['component_observability']:
    tracing_plateform_name=plateform['name']+"-tracing"
    var_web={
        'workspace-network': plateform['name'],
        'dns-name': 'tracing',
        'ami': 'ami-0d18c15886d01bddc',
        'port': '16686',
        'health_check': '/',
        'health_check_port': '16687'
    }
    create_component(working_dir='../terraform/component_web', plateform_name=tracing_plateform_name, var_component=var_web)

