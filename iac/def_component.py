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
      print("component " + self.component_name + " not in plateform : " + self.plateform['name'])
      return
    else:
      print("component " + self.component_name + " in plateform : " + self.plateform['name'])
    self.check()
    self.define_var()
    print("set workspace as " + self.plateform_name)
    self.workspace = self.plateform_name

  def get_constantes(self):
    self.bucket_component_state = self.plateform['bucket-component-state']
    self.plateform_name = self.plateform['name']

  def get_workspace(self):
    return self.workspace

  def define_var(self):
    self.var = {}

  def apply(self):
    pass

  def destroy(self):
    pass

  def check(self):
    pass

  def create(self, working_dir, var_component, skip_plan=True, plateform_name=""):

    if len(plateform_name) == 0:
      plateform_name = self.get_workspace()

    if os.path.exists(working_dir+"/.terraform/environment"):
      os.remove(working_dir+"/.terraform/environment")
    else:
      print("File environment not exist")
    
    if os.path.exists(working_dir+"/.terraform/terraform.tfstate"):
      os.remove(working_dir+"/.terraform/terraform.tfstate")
    else:
      print("File terraform.tfstate not exist")
    
    tf = Terraform(working_dir)
    tf.init(backend_config='bucket='+self.bucket_component_state, capture_output=False, no_color=IsNotFlagged)
    code, _, _ = tf.cmd("workspace select " + plateform_name, capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
      tf.cmd("workspace new " + plateform_name, capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, _, _ = tf.apply(
      var=var_component, 
      capture_output=False, 
      no_color=IsNotFlagged, 
      skip_plan=skip_plan,
      auto_approve=True)
    if code != 0:
      raise Exception("error in Terraform layer-base")

  def delete(self, working_dir, var_component, skip_plan=True, plateform_name=workspace):
    if os.path.exists(working_dir+"/.terraform/environment"):
      os.remove(working_dir+"/.terraform/environment")
    else:
      print("File environment not exist")

    if os.path.exists(working_dir+"/.terraform/terraform.tfstate"):
      os.remove(working_dir+"/.terraform/terraform.tfstate")
    else:
      print("File terraform.tfstate not exist")

    tf = Terraform(working_dir=working_dir)
    tf.init(backend_config='bucket='+self.bucket_component_state, capture_output=False, no_color=IsNotFlagged)
    code, _, _ = tf.cmd("workspace select " + plateform_name, capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
      print("workspace does not exist")
    else:
      code, _, _ = tf.destroy(
        var=var_component,
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=IsNotFlagged,
        auto_approve=True)
      if code != 0:
        raise Exception("error in Terraform layer-kubernetes")


  def output(self, var_name, working_dir, skip_plan=True, plateform_name=""):

    if len(plateform_name) == 0:
      plateform_name = self.get_workspace()

    print("search output : " + var_name)
    tf = Terraform(working_dir)
    code, out, _ = tf.cmd(
      "output " + var_name,
      no_color=IsNotFlagged)
    if code != 0:
      raise Exception("error in Terraform layer-base")
    return out