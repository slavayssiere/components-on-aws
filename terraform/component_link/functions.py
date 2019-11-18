#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component

class ComponentLink(Component):

  def define_var(self):
    pass

  def apply(self):
    if 'component_web' not in self.plateform:
      pass
    for web in self.plateform['component_web']:
      if 'link-rds' in web:
        print("create SG between " + web['name'] + " and web: " + web['link-rds'])
        self.compute_var(web, self.create)

  def destroy(self):
    if 'component_web' not in self.plateform:
      pass
    for web in self.plateform['component_web']:
      if 'link-rds' in web:
        self.compute_var(web, self.delete)
        

  def compute_var(self, web, func):
    if 'link-rds' not in web:
      pass
    
    tmp_plateform_name = self.plateform['name'] + "-" + web['name'] + "-" + web['link-rds']

    self.var = {
      'bucket_component_state': self.plateform['bucket-component-state'],
      'workspace-web': self.plateform['name'] + "-" + web['name'],
      'workspace-rds': self.plateform['name'] + "-" + web['link-rds'],
    }

    func( 
      working_dir='../terraform/component_link', 
      plateform_name=tmp_plateform_name, 
      var_component=self.var
    )

