#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from iac.yaml_check_error import YamlCheckError

class ComponentBase(Component):

  def define_var(self):
    enable_public_dns = True
    if 'public-dns' not in self.plateform:
      enable_public_dns = False
      self.plateform['public-dns']='not'

    self.var = {
      'account_id': self.plateform['account'],
      'region': self.plateform['region'],
      'public_dns': self.plateform['public-dns'],
      'enable_public_dns': enable_public_dns,
      'monthly_billing_threshold': self.plateform['billing-alert'],
      'email_address': self.plateform['billing-email']
    }
    
  def apply(self):
    self.create(
      working_dir='../terraform/component_base',
      plateform_name=self.plateform_name,
      var_component=self.var, 
      skip_plan=True
    )

  def destroy(self):
    self.delete(
      working_dir='../terraform/component_base',
      plateform_name=self.plateform_name,
      var_component=self.var
    )

  def check(self):
    if 'name' not in self.plateform:
        raise YamlCheckError('base', 'please add name of plateform')
    if 'type' not in self.plateform:
        raise YamlCheckError('base', 'please add type of plateform')
    if 'account' not in self.plateform:
        raise YamlCheckError('base', 'please add aws account of plateform')
    if 'region' not in self.plateform:
        raise YamlCheckError('base', 'please add aws region of plateform')
    if 'public-dns' not in self.plateform:
        raise YamlCheckError('base', 'please add public-dns SOA of plateform')
