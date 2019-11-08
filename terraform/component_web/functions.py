#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component

def apply(web, plateform_name, account):
    web_plateform_name = plateform_name + "-" + web['name']
    print("Create " + web_plateform_name + " web")
    if 'health-check-port' not in web:
        health_check_port = web['port']
    else:
        health_check_port = web['health-check-port']

    ami_account = account
    if 'ami-account' in web:
        ami_account = web['ami-account']

    var_web={
        'workspace-network': plateform_name,
        'dns-name': web['name'],
        'ami-name': web['ami-name'],
        'ami-account': ami_account,
        'user-data': web['user-data'],
        'port': web['port'],
        'health_check': web['health-check'],
        'health_check_port': health_check_port
    }
    create_component(working_dir='../terraform/component_web', plateform_name=web_plateform_name, var_component=var_web)
