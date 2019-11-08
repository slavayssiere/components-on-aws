#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from iac.yaml_check_error import YamlCheckError
from iac.aws_object import get_secret_value

def apply(bucket_component_state, rds, plateform_name, is_prod):
  rds_plateform_name = plateform_name + "-" + rds['name']
  print("Create " + rds_plateform_name + " rds")
  var_rds={
      'bucket_component_state': bucket_component_state,
      'workspace-network': plateform_name,
      'dns-name': rds['name'],
      'deletion_protection': is_prod,
      'multi_az': is_prod,
      'password': get_secret_value(rds_plateform_name)
  }
  create_component(working_dir='../terraform/component_rds', plateform_name=rds_plateform_name, var_component=var_rds)

def destroy(bucket_component_state, rds, plateform_name, is_prod):
  rds_plateform_name = plateform_name + "-" + rds['name']
  print("Delete " + rds_plateform_name + " rds")
  var_rds={
      'bucket_component_state': bucket_component_state,
      'workspace-network': plateform_name,
      'dns-name': rds['name'],
      'deletion_protection': is_prod,
      'multi_az': is_prod,
      'password': get_secret_value(rds_plateform_name)
  }
  delete_component(working_dir='../terraform/component_rds', plateform_name=rds_plateform_name, var_component=var_rds)

def check(plateform):
    if 'component_network' not in plateform:
        raise YamlCheckError('rds', 'component_network is mandatory')
    if not isinstance(plateform['component_rds'], list):
        raise YamlCheckError('rds', 'component_rds should be a list')
    pass

