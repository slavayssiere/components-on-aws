#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from iac.yaml_check_error import YamlCheckError

def apply(plateform):
  ## component base
  var_base={
    'account_id': plateform['account'],
    'region': plateform['region'],
    'public_dns': plateform['public-dns'],
    'monthly_billing_threshold': plateform['billing-alert']
  }
  create_component(working_dir='../terraform/component_base', plateform_name=plateform['name'], var_component=var_base)

def destroy(plateform):
  ## component base
  var_base={
    'account_id': plateform['account'],
    'region': plateform['region'],
    'public_dns': plateform['public-dns'],
    'monthly_billing_threshold': plateform['billing-alert']
  }
  delete_component(working_dir='../terraform/component_base', plateform_name=plateform['name'], var_component=var_base)

def check(plateform):
  if 'name' not in plateform:
      raise YamlCheckError('base', 'please add name of plateform')
  if 'type' not in plateform:
      raise YamlCheckError('base', 'please add type of plateform')
  if 'account' not in plateform:
      raise YamlCheckError('base', 'please add aws account of plateform')
  if 'region' not in plateform:
      raise YamlCheckError('base', 'please add aws region of plateform')
  if 'public-dns' not in plateform:
      raise YamlCheckError('base', 'please add public-dns SOA of plateform')
