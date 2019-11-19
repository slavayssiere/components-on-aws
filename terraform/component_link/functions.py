#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component

class ComponentLink(Component):

  blocname = ""
  component_name = "link"

  def define_var(self):
    pass

  def apply(self):
    if 'component_web' in self.plateform_name:
      for web in self.plateform['component_web']:
        if 'link-rds' in web:
          print("create SG between " + web['name'] + " and web: " + web['link-rds'])
          self.compute_var_web(web, self.create)

    if 'component_eks' in self.plateform:
      if 'link-rds' in self.plateform['component_eks']:
        print("create SG between EKS and RDS: " + self.plateform['component_eks']['link-rds'])
        self.compute_var_eks(self.create)

  def destroy(self):
    if 'component_web' in self.plateform_name:
      for web in self.plateform['component_web']:
        if 'link-rds' in web:
          self.compute_var_web(web, self.delete)

    if 'component_eks' in self.plateform:
      if 'link-rds' in self.plateform['component_eks']:
        self.compute_var_eks(self.delete)
        

  def compute_var_web(self, web, func):
    tmp_plateform_name = self.plateform['name'] + "-" + web['name'] + "-" + web['link-rds']

    self.var = {
      'bucket_component_state': self.plateform['bucket-component-state'],
      'workspace': self.plateform['name'] + "-" + web['name'],
      'workspace-rds': self.plateform['name'] + "-" + web['link-rds'],
      'is_eks': False,
      'is_web': True
    }

    func( 
      working_dir='../terraform/component_link', 
      plateform_name=tmp_plateform_name, 
      var_component=self.var
    )


  def compute_var_eks(self, func):
    tmp_plateform_name = self.plateform['name'] + "-eks-" + self.plateform['component_eks']['link-rds']

    self.var = {
      'bucket_component_state': self.plateform['bucket-component-state'],
      'workspace': self.plateform['name'],
      'workspace-rds': self.plateform['name'] + "-" + self.plateform['component_eks']['link-rds'],
      'is_eks': True,
      'is_web': False
    }

    func( 
      working_dir='../terraform/component_link', 
      plateform_name=tmp_plateform_name, 
      var_component=self.var
    )

