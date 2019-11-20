#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from terraform.component_web.functions import ComponentWeb
from terraform.component_eks.functions import ComponentEKS
from terraform.component_rds.functions import ComponentRDS

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

  def get_workspace_web(self, web_name, link_rds):
    return self.plateform['name'] + "-link-" + web_name + "-" + link_rds    

  def compute_var_web(self, web, func):

    web_component = ComponentWeb(self.plateform)
    rds_component = ComponentRDS(self.plateform)

    self.var = {
      'bucket_component_state': self.plateform['bucket-component-state'],
      'workspace-web': web_component.get_workspace(web['name']),
      'workspace-eks': '',
      'workspace-rds': rds_component.get_workspace(web['link-rds']),
      'is_eks': False,
      'is_web': True
    }

    func( 
      working_dir='../terraform/component_link', 
      plateform_name=self.get_workspace_web(web['name'], web['link-rds']), 
      var_component=self.var
    )

  def get_workspace_eks(self, link_rds):
    return self.plateform['name'] + "-link-eks-" + link_rds


  def compute_var_eks(self, func):

    eks_component = ComponentEKS(self.plateform)
    rds_component = ComponentRDS(self.plateform)

    self.var = {
      'bucket_component_state': self.plateform['bucket-component-state'],
      'workspace-eks': eks_component.get_workspace(),
      'workspace-web': '',
      'workspace-rds': rds_component.get_workspace(self.plateform['component_eks']['link-rds']),
      'is_eks': True,
      'is_web': False
    }

    func( 
      working_dir='../terraform/component_link', 
      plateform_name=self.get_workspace_eks(self.plateform['component_eks']['link-rds']), 
      var_component=self.var
    )

