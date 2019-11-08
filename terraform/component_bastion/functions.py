#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component

def apply(plateform):

  # enable EKS is used for open SG between bastion and master
  enable_eks = False
  if 'component_eks' in plateform:
    enable_eks = True

  create_component(working_dir='../terraform/component_bastion', plateform_name=plateform['name'], var_component={'enable_eks': enable_eks})

def destroy(plateform):
  # enable EKS is used for open SG between bastion and master
  enable_eks = False
  if 'component_eks' in plateform:
    enable_eks = True

  delete_component(working_dir='../terraform/component_bastion', plateform_name=plateform['name'], var_component={'enable_eks': enable_eks})