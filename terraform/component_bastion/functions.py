#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from iac.yaml_check_error import YamlCheckError

class ComponentBastion(Component):

  def define_var(self):
    # enable EKS is used for open SG between bastion and master
    enable_eks = False
    if 'component_eks' in self.plateform:
      enable_eks = True

    self.var = {
      'enable_eks': enable_eks,
      'bucket_component_state': self.bucket_component_state
    }

def apply(self):
  if 'component_bastion' not in self.plateform:
    pass
  
  self.create(
    working_dir='../terraform/component_bastion', 
    plateform_name=self.plateform_name, 
    var_component=self.var
  )

def destroy(self):
  self.delete(
    working_dir='../terraform/component_bastion', 
    plateform_name=self.plateform_name,
    var_component=self.var_component
  )

def check(plateform):
    if 'component_network' not in plateform:
        raise YamlCheckError('bastion', 'component_network is mandatory')
    pass