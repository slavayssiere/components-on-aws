from functions_terraform import delete_component
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


        # to allow multi_az, deletion_protection and others
        is_prod = False
        account = plateform['account']
        plateform_name = plateform['nom']

        print("Will delete plateform: " + plateform_name + " in account:" + account)

        if 'component-rds' in plateform:
            print("delete rds")
            for rds in plateform['component-rds']:
                rds_plateform_name = plateform_name + "-" + rds['name']
                print("Delete " + rds_plateform_name + " rds")
                var_rds={
                    'workspace-network': plateform_name
                }
                delete_component(working_dir='../terraform/component-rds', plateform_name=rds_plateform_name, var_component=var_rds)

        if 'component-bastion' in plateform:
            print("delete bastion")
            eks_enabled = False
            if 'component-eks' in plateform:
                eks_enabled = True
            delete_component(working_dir='../terraform/component-bastion', plateform_name=plateform_name, var_component={'enable_eks': eks_enabled})

        ## component eks
        if 'component-eks' in plateform:
            print("delete alb")
            delete_component(working_dir='../terraform/component-eks/component-alb', plateform_name=plateform_name, var_component={})
            print("delete eks")
            delete_component(working_dir='../terraform/component-eks', plateform_name=plateform_name, var_component={})
           
        ## component network
        if 'component-network' in plateform:
            print("delete network")
            delete_component(working_dir='../terraform/component-network', plateform_name=plateform_name, var_component={})
 
        ## component base
        print("delete base")
        var_base={
            'account_id': account,
        }
        delete_component(working_dir='../terraform/component-base', plateform_name=plateform_name, var_component=var_base)

    except yaml.YAMLError as exc:
        print(exc)
    except Exception as inst:
        print(inst)