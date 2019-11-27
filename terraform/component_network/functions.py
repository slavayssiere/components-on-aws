#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from iac.yaml_check_error import YamlCheckError

class ComponentNetwork(Component):

  blocname = "component_network"
  component_name = "network"

  def define_var(self):
    self.var = {
      'private_dns_zone': self.plateform[self.blocname]['private-dns']
    }
    if 'nat' in self.plateform[self.blocname]:
      self.var['enable_nat_gateway']= self.plateform[self.blocname]['nat-gateway']

  def apply(self):
    if self.blocname not in self.plateform:
      return

    self.create(
      working_dir='../terraform/component_network',
      var_component=self.var
    )

  def destroy(self):
    if self.blocname not in self.plateform:
      return
    
    self.delete(
      working_dir='../terraform/component_network',
      var_component=self.var
    )

  def check(self):
    if 'private-dns' not in self.plateform[self.blocname]:
      raise YamlCheckError(self.component_name, 'please add private-dns of plateform')