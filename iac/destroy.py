from functions_terraform import delete_component
from yaml_check import check_yaml, YamlCheckError
import subprocess
import yaml
import sys 

if len(sys.argv) > 1:
    name_file = sys.argv[1]
    print("create from file: ../plateform/" + name_file + ".yaml")
else:
    name_file = input("Nom du fichier: ")

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

with open("../plateform/"+name_file+".yaml", 'r') as stream:
    try:
        plateform=yaml.load(stream, Loader=Loader)

        # validate YAML
        check_yaml(plateform)

        # to allow multi_az, deletion_protection and others
        is_prod = False
        account = plateform['account']
        plateform_name = plateform['name']

        print("Will delete plateform: " + plateform_name + " in account:" + account)

        if 'component_rds' in plateform:
            print("delete rds")
            for rds in plateform['component_rds']:
                rds_plateform_name = plateform_name + "-" + rds['name']
                print("Delete " + rds_plateform_name + " rds")
                var_rds={
                    'workspace-network': plateform_name,
                    'password': "temp-for-remove"
                }
                delete_component(working_dir='../terraform/component_rds', plateform_name=rds_plateform_name, var_component=var_rds)

        if 'component_bastion' in plateform:
            print("delete bastion")
            eks_enabled = False
            if 'component_eks' in plateform:
                eks_enabled = True
            delete_component(working_dir='../terraform/component_bastion', plateform_name=plateform_name, var_component={'enable_eks': eks_enabled})

        ## component eks
        if 'component_eks' in plateform:
            print("delete alb")
            delete_component(working_dir='../terraform/component_eks/component_alb', plateform_name=plateform_name, var_component={})
            print("delete eks")
            delete_component(working_dir='../terraform/component_eks', plateform_name=plateform_name, var_component={})
           
        ## component network
        if 'component_network' in plateform:
            print("delete network")
            delete_component(working_dir='../terraform/component_network', plateform_name=plateform_name, var_component={})
 
        ## component base
        print("delete base")
        var_base={
            'account_id': account,
        }
        delete_component(working_dir='../terraform/component_base', plateform_name=plateform_name, var_component=var_base)

    except yaml.YAMLError as exc:
        print(exc)
    except Exception as inst:
        print(inst)