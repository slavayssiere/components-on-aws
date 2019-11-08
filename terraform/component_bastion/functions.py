#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component
from iac.yaml_check import YamlCheckError

def apply(bucket_component_state, plateform):

  # enable EKS is used for open SG between bastion and master
  enable_eks = False
  if 'component_eks' in plateform:
    enable_eks = True

  create_component(working_dir='../terraform/component_bastion', plateform_name=plateform['name'], var_component={'enable_eks': enable_eks, 'bucket_component_state': bucket_component_state})

def destroy(bucket_component_state, plateform):
  # enable EKS is used for open SG between bastion and master
  enable_eks = False
  if 'component_eks' in plateform:
    enable_eks = True

  delete_component(working_dir='../terraform/component_bastion', plateform_name=plateform['name'], var_component={'enable_eks': enable_eks, 'bucket_component_state': bucket_component_state})

def check(plateform):
    if 'component_network' not in plateform:
        raise YamlCheckError('bastion', 'component_network is mandatory')
    pass