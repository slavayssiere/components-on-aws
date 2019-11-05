from python_terraform import Terraform, IsNotFlagged, IsFlagged    

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

def delete_component(working_dir, plateform_name, var_component):
    tf = Terraform(working_dir=working_dir)
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
