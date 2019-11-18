#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from iac.yaml_check_error import YamlCheckError

class ComponentNetwork(Component):

  def define_var(self):
    self.var = {
      'private_dns_zone': self.plateform['private-dns']
    }

  def apply(self):
    if 'component_network' not in self.plateform:
      pass

    self.create(
      working_dir='../terraform/component_network', 
      plateform_name=self.plateform_name, 
      var_component=self.var
    )

  def destroy(self):
    self.delete(
      working_dir='../terraform/component_network', 
      plateform_name=self.plateform_name, 
      var_component=self.var
    )

  def check(plateform):
      pass