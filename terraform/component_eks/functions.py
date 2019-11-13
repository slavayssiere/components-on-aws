#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from iac.yaml_check_error import YamlCheckError
from terraform.component_bastion.functions import apply as apply_bastion
import subprocess

def apply(bucket_component_state, plateform):

  network_type = plateform['component_eks']['network-type']

  create_component(working_dir='../terraform/component_eks', plateform_name=plateform['name'], var_component={'bucket_component_state': bucket_component_state})

  ## need bastion for folowing
  apply_bastion(bucket_component_state, plateform)

  ## launch eks script
  print("Post Apply script execution...")
  subprocess.call(["../terraform/component_eks/apply.sh", plateform['name'], network_type, plateform['account'], plateform['public-dns'], plateform['private-dns']])
  create_component(working_dir='../terraform/component_eks/component-alb', plateform_name=plateform['name'], var_component={'bucket_component_state': bucket_component_state})

  # we do not need a bastion
  if 'component_bastion' in plateform:
      print("do not delete bastion")
  else:
      delete_component(working_dir='../terraform/component_bastion', plateform_name=plateform['name'], var_component={})

def destroy(bucket_component_state, plateform):
    print("delete alb")
    delete_component(working_dir='../terraform/component_eks/component-alb', plateform_name=plateform['name'], var_component={'bucket_component_state': bucket_component_state})
    print("delete eks")
    delete_component(working_dir='../terraform/component_eks', plateform_name=plateform['name'], var_component={'bucket_component_state': bucket_component_state})
        

def check(plateform):
    # dependencies test
    if 'component_network' not in plateform:
        raise YamlCheckError('eks', 'component_network is mandatory')
    
    # component struct test
    component = plateform['component_eks']
    if 'network-type' not in component:
        raise YamlCheckError('eks', 'network-type is missing')
    pass