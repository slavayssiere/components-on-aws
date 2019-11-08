#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from iac.yaml_check import YamlCheckError

def apply(bucket_component_state, web, plateform_name, account):
    web_plateform_name = plateform_name + "-" + web['name']
    print("Create " + web_plateform_name + " web")
    if 'health-check-port' not in web:
        health_check_port = web['port']
    else:
        health_check_port = web['health-check-port']

    ami_account = account
    if 'ami-account' in web:
        ami_account = web['ami-account']

    user_data = ''
    if 'user-data' in web:
        user_data = web['user-data']

    var_web={
        'bucket_component_state': bucket_component_state,
        'workspace-network': plateform_name,
        'dns-name': web['name'],
        'ami-name': web['ami-name'],
        'ami-account': ami_account,
        'user-data': user_data,
        'port': web['port'],
        'health_check': web['health-check'],
        'health_check_port': health_check_port
    }
    create_component(working_dir='../terraform/component_web', plateform_name=web_plateform_name, var_component=var_web)

def destroy(bucket_component_state, web, plateform_name, account):
    web_plateform_name = plateform_name + "-" + web['name']
    print("Delete " + web_plateform_name + " web")
    if 'health-check-port' not in web:
        health_check_port = web['port']
    else:
        health_check_port = web['health-check-port']

    ami_account = account
    if 'ami-account' in web:
        ami_account = web['ami-account']

    user_data = ''
    if 'user-data' in web:
        user_data = web['user-data']

    var_web={
        'bucket_component_state': bucket_component_state,
        'workspace-network': plateform_name,
        'dns-name': web['name'],
        'ami-name': web['ami-name'],
        'ami-account': ami_account,
        'user-data': user_data,
        'port': web['port'],
        'health_check': web['health-check'],
        'health_check_port': health_check_port
    }
    delete_component(working_dir='../terraform/component_web', plateform_name=web_plateform_name, var_component=var_web)

def check(plateform):
    if 'component_network' not in plateform:
        raise YamlCheckError('web', 'component_network is mandatory')
    if not isinstance(plateform['component_web'], list):
        raise YamlCheckError('web', 'component_web should be a list')
    pass