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
          self.compute_var(web, self.create, is_eks=False, is_web=True)

    if 'component_eks' in self.plateform:
      if 'link-rds' in self.plateform['component_eks']:
        print("create SG between EKS and RDS: " + self.plateform['component_eks']['link-rds'])
        self.compute_var(web, self.create, is_eks=True, is_web=False)

  def destroy(self):
    if 'component_web' in self.plateform_name:
      for web in self.plateform['component_web']:
        if 'link-rds' in web:
          self.compute_var(web, self.delete, is_eks=False, is_web=True)

    if 'component_eks' in self.plateform:
      if 'link-rds' in self.plateform['component_eks']:
        self.compute_var(web, self.delete, is_eks=True, is_web=False)
        

  def compute_var(self, web, func, is_eks=False, is_web=False):
    tmp_plateform_name = self.plateform['name'] + "-" + web['name'] + "-" + web['link-rds']

    self.var = {
      'bucket_component_state': self.plateform['bucket-component-state'],
      'workspace': self.plateform['name'] + "-" + web['name'],
      'workspace-rds': self.plateform['name'] + "-" + web['link-rds'],
      'is_eks': is_eks,
      'is_web': is_web
    }

    func( 
      working_dir='../terraform/component_link', 
      plateform_name=tmp_plateform_name, 
      var_component=self.var
    )

