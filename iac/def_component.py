#!/usr/bin/env python3

import os

from python_terraform import Terraform, IsNotFlagged, IsFlagged    

class Component:

  blocname = ""
  component_name = ""
  workspace = ""
  
  def __init__(self, plateform):
    self.plateform = plateform
    self.get_constantes()
    if self.blocname not in plateform:
      return
    self.check()
    self.define_var()
    self.workspace = self.plateform_name

  def get_constantes(self):
    self.bucket_component_state = self.plateform['bucket-component-state']
    self.plateform_name = self.plateform['name']

    if 'region' not in self.plateform:
      self.plateform['region']='eu-west-1'

    self.region = self.plateform['region']

  def get_workspace(self):
    return self.workspace

  def define_var(self):
    self.var = {}

  def apply(self):
    pass

  def destroy(self):
    pass

  # to check:
  # - dependancies (exemple: rds need network)
  # - yaml validation for component
  def check(self):
    pass

  def init(self, working_dir):
    self.tf = Terraform(working_dir)
    self.tf.cmd(
      "init -backend-config=bucket=" + self.bucket_component_state + " -backend-config=region=" + self.region,
      capture_output=True,
      no_color=IsNotFlagged
    )

  def create(self, working_dir, var_component, skip_plan=True, workspace_name=""):

    if len(workspace_name) == 0:
      workspace_name = self.get_workspace()

    if os.path.exists(working_dir+"/.terraform/environment"):
      os.remove(working_dir+"/.terraform/environment")
    else:
      print("File environment not exist")
    
    if os.path.exists(working_dir+"/.terraform/terraform.tfstate"):
      os.remove(working_dir+"/.terraform/terraform.tfstate")
    else:
      print("File terraform.tfstate not exist")
    
    self.init(working_dir=working_dir)
    
    # select workspace
    code, _, _ = self.tf.cmd("workspace select " + workspace_name, capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
      self.tf.cmd("workspace new " + workspace_name, capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    
    # terraform apply
    code, _, _ = tf.apply(
      var=var_component, 
      capture_output=False, 
      no_color=IsNotFlagged, 
      skip_plan=skip_plan,
      auto_approve=True)
    if code != 0:
      raise Exception("error in component: " + self.component_name)

  def delete(self, working_dir, var_component, skip_plan=True, workspace_name=""):
    if len(workspace_name) == 0:
      workspace_name = self.get_workspace()

    if os.path.exists(working_dir+"/.terraform/environment"):
      os.remove(working_dir+"/.terraform/environment")
    else:
      print("File environment not exist")

    if os.path.exists(working_dir+"/.terraform/terraform.tfstate"):
      os.remove(working_dir+"/.terraform/terraform.tfstate")
    else:
      print("File terraform.tfstate not exist")
    
    self.init(working_dir=working_dir)
    
    code, _, _ = self.tf.cmd("workspace select " + workspace_name, capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
      print("workspace does not exist")
    else:
      code, _, _ = self.tf.destroy(
        var=var_component,
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)
      if code != 0:
        raise Exception("error in component: " + self.component_name)

  def output(self, var_name, working_dir, skip_plan=True, workspace_name=""):

    if len(workspace_name) == 0:
      workspace_name = self.get_workspace()

    print("search output : " + var_name)

    self.tf = Terraform(working_dir)

    out = ''

    code, _, _ = self.tf.cmd("workspace select " + workspace_name, capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
      print("workspace does not exist")
    else:
      code, out, _ = self.tf.cmd(
        "output " + var_name,
        no_color=IsNotFlagged)
      if code != 0:
        raise Exception("error in component: " + self.component_name)

    return out