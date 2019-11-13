#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from iac.yaml_check_error import YamlCheckError

def apply(plateform):
  var = {
    'private_dns_zone': plateform['private-dns']
  }
  create_component(bucket_component_state=plateform['bucket-component-state'], working_dir='../terraform/component_network', plateform_name=plateform['name'], var_component=var)

def destroy(plateform):
  var = {
    'private_dns_zone': plateform['private-dns']
  }
  delete_component(bucket_component_state=plateform['bucket-component-state'], working_dir='../terraform/component_network', plateform_name=plateform['name'], var_component=var)

def check(plateform):
    pass