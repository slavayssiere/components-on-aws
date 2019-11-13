#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from iac.yaml_check_error import YamlCheckError
from iac.aws_object import get_secret_value, get_parameter_value

def apply(bucket_component_state, rds, plateform_name, is_prod):
  rds_plateform_name = plateform_name + "-" + rds['name']
  snapshot_enable = False
  snapshot_name = ''
  if 'snapshot_name' in rds:
      snapshot_enable = True
      snapshot_name = rds['snapshot_name']

  snapshot_parameter_name = 'snapshot-rds-'+plateform_name+"-" + rds['name']
  snapshot_id = get_parameter_value(snapshot_parameter_name)

  if snapshot_id == rds['snapshot_name']:
    snapshot_enable = False
    snapshot_name = ''

  print("Create " + rds_plateform_name + " rds")
  var_rds={
      'bucket_component_state': bucket_component_state,
      'workspace-network': plateform_name,
      'dns-name': rds['name'],
      'deletion_protection': is_prod,
      'multi_az': is_prod,
      'password': get_secret_value(rds_plateform_name),
      'snapshot_enable': snapshot_enable,
      'snapshot_name': snapshot_name,
      'engine': rds['engine'],
      'engine_version': rds['engine_version'],
      'snapshot_rds_paramater_name': snapshot_parameter_name
  }
  create_component(bucket_component_state=bucket_component_state, working_dir='../terraform/component_rds', plateform_name=rds_plateform_name, var_component=var_rds)

def destroy(bucket_component_state, rds, plateform_name, is_prod):
  rds_plateform_name = plateform_name + "-" + rds['name']
  print("Delete " + rds_plateform_name + " rds")
  snapshot_enable = False
  snapshot_name = ''
  if 'snapshot_name' in rds:
      snapshot_enable = True
      snapshot_name = rds['snapshot_name']
      
  var_rds={
      'bucket_component_state': bucket_component_state,
      'workspace-network': plateform_name,
      'dns-name': rds['name'],
      'deletion_protection': is_prod,
      'multi_az': is_prod,
      'password': 'tmp_to_delete',
      'snapshot_enable': snapshot_enable,
      'snapshot_name': snapshot_name,
      'engine': 'mysql',
      'engine_version': '5.7'
  }
  delete_component(bucket_component_state=bucket_component_state, working_dir='../terraform/component_rds', plateform_name=rds_plateform_name, var_component=var_rds)

def check(plateform):
    if 'component_network' not in plateform:
        raise YamlCheckError('rds', 'component_network is mandatory')
    if not isinstance(plateform['component_rds'], list):
        raise YamlCheckError('rds', 'component_rds should be a list')
    pass

