#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component

def apply(plateform):
    for web in plateform['component_web']:
        if 'link-rds' in web:
            print("create SG between " + web['name'] + " and web: " + web['link-rds'])
            var = {
                'bucket_component_state': plateform['bucket-component-state'],
                'workspace-web': plateform['name'] + "-" + web['name'],
                'workspace-rds': plateform['name'] + "-" + web['link-rds'],
            }
            create_component(plateform['bucket-component-state'], working_dir='../terraform/component_link', plateform_name=plateform['name'], var_component=var)


def destroy(plateform):
    for web in plateform['component_web']:
        if 'link-rds' in web:
            print("create SG between " + web['name'] + " and web: " + web['link-rds'])
            var = {
                'bucket_component_state': plateform['bucket-component-state'],
                'workspace-web': plateform['name'] + "-" + web['name'],
                'workspace-rds': plateform['name'] + "-" + web['link-rds'],
            }
            delete_component(plateform['bucket-component-state'], working_dir='../terraform/component_link', plateform_name=plateform['name'], var_component=var)
