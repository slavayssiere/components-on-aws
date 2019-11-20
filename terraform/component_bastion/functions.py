#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from iac.yaml_check_error import YamlCheckError

class ComponentBastion(Component):

  blocname = "component_bastion"
  component_name = "bastion"

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
    if self.blocname not in self.plateform:
      return
    
    self.create(
      working_dir='../terraform/component_bastion',
      var_component=self.var
    )

  def destroy(self):
    if self.blocname not in self.plateform:
      return

    self.delete(
      working_dir='../terraform/component_bastion',
      var_component=self.var
    )

  def check(self):
    if 'component_network' not in self.plateform:
        raise YamlCheckError('bastion', 'component_network is mandatory')