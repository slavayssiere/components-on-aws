#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from terraform.component_bastion.apply import apply as apply_bastion
import subprocess

def apply(plateform):

  network_type = plateform['component_eks']['network-type']

  create_component(working_dir='../terraform/component_eks', plateform_name=plateform['name'], var_component={})

  ## need bastion for folowing
  apply_bastion(plateform)

  ## launch eks script
  print("Post Apply script execution...")
  subprocess.call(["../terraform/component_eks/apply.sh", plateform['name'], network_type, plateform['account']])
  create_component(working_dir='../terraform/component_eks/component_alb', plateform_name=plateform['name'], var_component={})

  # we do not need a bastion
  if 'component_bastion' in plateform:
      print("do not delete bastion")
  else:
      delete_component(working_dir='../terraform/component_bastion', plateform_name=plateform['name'], var_component={})
