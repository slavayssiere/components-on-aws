import os
from python_terraform import Terraform, IsNotFlagged, IsFlagged    

def create_component(bucket_component_state, working_dir, plateform_name, var_component, skip_plan=True):
    if os.path.exists(working_dir+"/.terraform/environment"):
        os.remove(working_dir+"/.terraform/environment")
    else:
        print("File environment not exist")
    
    if os.path.exists(working_dir+"/.terraform/terraform.tfstate"):
        os.remove(working_dir+"/.terraform/terraform.tfstate")
    else:
        print("File terraform.tfstate not exist")
    
    tf = Terraform(working_dir)
    tf.init(backend_config='bucket='+bucket_component_state, capture_output=False, no_color=IsNotFlagged)
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

def delete_component(bucket_component_state, working_dir, plateform_name, var_component):
    if os.path.exists(working_dir+"/.terraform/environment"):
        os.remove(working_dir+"/.terraform/environment")
    else:
        print("File environment not exist")
    
    if os.path.exists(working_dir+"/.terraform/terraform.tfstate"):
        os.remove(working_dir+"/.terraform/terraform.tfstate")
    else:
        print("File terraform.tfstate not exist")
    
    tf = Terraform(working_dir=working_dir)
    tf.init(backend_config='bucket='+bucket_component_state, capture_output=False, no_color=IsNotFlagged)
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
