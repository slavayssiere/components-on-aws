from python_terraform import Terraform, IsNotFlagged, IsFlagged    
import subprocess

# source YAML here
plateform_name='calico'
network_type='calico'
account='549637939820'

def create_component(working_dir, plateform_name, var_component):
    tf = Terraform(working_dir)
    code, _, _ = tf.cmd("workspace select " + plateform_name, capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    if code == 1:
        tf.cmd("workspace new " + plateform_name, capture_output=False, no_color=IsNotFlagged, skip_plan=IsNotFlagged)
    code, _, _ = tf.apply(
        var=var_component, 
        capture_output=False, 
        no_color=IsNotFlagged, 
        skip_plan=True,
        auto_approve=True)
    if code != 0:
        raise Exception("error in Terraform layer-base")


## component base
create_component(working_dir='../terraform/component-base', plateform_name=plateform_name, var_component={'account_id': account})

## component network
create_component(working_dir='../terraform/component-network', plateform_name=plateform_name, var_component={})

## component eks
create_component(working_dir='../terraform/component-eks', plateform_name=plateform_name, var_component={})

## component bastion
create_component(working_dir='../terraform/component-bastion', plateform_name=plateform_name, var_component={})

# # launch eks script
# print("Post Apply script execution...")
# subprocess.call(["../terraform/component-eks/apply.sh", plateform_name, network_type, account])
# create_component(working_dir='terraform/component-eks/component-alb', plateform_name=plateform_name, var_component={})
