#!/usr/bin/env python3

import sys

sys.path.insert(1, '../..')

from iac.def_component import Component
from iac.yaml_check_error import YamlCheckError

class ComponentBase(Component):

  blocname = "name"
  component_name = "base"

  def define_var(self):
    enable_public_dns = True
    if 'public-dns' not in self.plateform:
      enable_public_dns = False
      self.plateform['public-dns']='not'

    self.var = {
      'account_id': self.plateform['account'],
      'public_dns': self.plateform['public-dns'],
      'enable_public_dns': enable_public_dns,
      'monthly_billing_threshold': self.plateform['billing-alert'],
      'email_address': self.plateform['billing-email']
    }
    # i use the default TF var
    if 'region' in self.plateform:
      self.var['region']=self.plateform['region']
    
  def apply(self):
    self.create(
      working_dir='../terraform/component_base',
      var_component=self.var
    )

  def destroy(self):
    self.delete(
      working_dir='../terraform/component_base',
      var_component=self.var
    )

  def check(self):
    if 'name' not in self.plateform:
        raise YamlCheckError(self.component_name, 'please add name of plateform')
    if 'type' not in self.plateform:
        raise YamlCheckError(self.component_name, 'please add type of plateform')
    if 'account' not in self.plateform:
        raise YamlCheckError(self.component_name, 'please add aws account of plateform')
    if 'billing-alert' not in self.plateform:
        raise YamlCheckError(self.component_name, 'please add billing-alert of plateform')
    if 'billing-email' not in self.plateform:
        raise YamlCheckError(self.component_name, 'please add billing-email of plateform')
