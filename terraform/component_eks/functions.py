#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from iac.yaml_check_error import YamlCheckError
from terraform.component_bastion.functions import ComponentBastion
import subprocess

class ComponentEKS(Component):

  def define_var(self):
    self.var = {'bucket_component_state': self.bucket_component_state}

  def apply(self):
    if 'component_eks' not in self.plateform:
      pass

    bastion = ComponentBastion(self.plateform)

    self.create(
      working_dir='../terraform/component_eks', 
      plateform_name=self.plateform['name'], 
      var_component=self.var
    )

    ## need bastion for folowing
    bastion.apply()

    ## launch eks script
    print("Post Apply script execution...")
    subprocess.call([
      "../terraform/component_eks/apply.sh",
      self.plateform_name,
      self.plateform['component_eks']['network-type'], 
      self.plateform['account'], 
      self.plateform['public-dns'], 
      self.plateform['private-dns']
    ])
    
    self.create(
      working_dir='../terraform/component_eks/component-alb', 
      plateform_name=self.plateform_name, 
      var_component=self.var
    )

    # we do not need a bastion
    if 'component_bastion' in self.plateform:
        print("do not delete bastion")
    else:
        bastion.destroy()

  def destroy(self):
    print("delete alb")
    self.delete(
      working_dir='../terraform/component_eks/component-alb', 
      plateform_name=self.plateform_name, 
      var_component=self.var
    )
    print("delete eks")
    self.delete(
      working_dir='../terraform/component_eks', 
      plateform_name=self.plateform_name, 
      var_component=self.var
    )
          
  def check(self):
    # dependencies test
    if 'component_network' not in self.plateform:
        raise YamlCheckError('eks', 'component_network is mandatory')
    
    # component struct test
    component = self.plateform['component_eks']
    if 'network-type' not in component:
        raise YamlCheckError('eks', 'network-type is missing')
    pass