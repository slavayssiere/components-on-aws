#!/usr/bin/env python3

from functions_terraform import create_component, delete_component
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
        if plateform['type'] == "prod":
            is_prod = True
        
        account = plateform['account']
        plateform_name = plateform['nom']

        print("Will create plateform: " + plateform_name + " in account:" + account)

        ## component base
        var_base={
            'account_id': account,
            'region': plateform['region'],
            'public_dns': plateform['public-dns']
        }
        create_component(working_dir='../terraform/component-base', plateform_name=plateform_name, var_component=var_base)

        ## component network
        if 'component-network' in plateform:
            create_component(working_dir='../terraform/component-network', plateform_name=plateform_name, var_component={})

        ## component eks
        if 'component-eks' in plateform:

            network_type = plateform['component-eks']['network-type']

            create_component(working_dir='../terraform/component-eks', plateform_name=plateform_name, var_component={})
            ## need bastion for folowing
            create_component(working_dir='../terraform/component-bastion', plateform_name=plateform_name, var_component={})
            ## launch eks script
            print("Post Apply script execution...")
            subprocess.call(["../terraform/component-eks/apply.sh", plateform_name, network_type, account])
            create_component(working_dir='../terraform/component-eks/component-alb', plateform_name=plateform_name, var_component={})

            # we do not need a bastion
            if 'component-bastion' in plateform:
                print("do not delete bastion")
            else:
                delete_component(working_dir='../terraform/component-bastion', plateform_name=plateform_name, var_component={})

        if 'component-rds' in plateform:
            for rds in plateform['component-rds']:
                rds_plateform_name = plateform_name + "-" + rds['name']
                print("Create " + rds_plateform_name + " rds")
                var_rds={
                    'workspace-network': plateform_name,
                    'dns-name': rds['name'],
                    'deletion_protection': is_prod,
                    'multi_az': is_prod
                }
                create_component(working_dir='../terraform/component-rds', plateform_name=rds_plateform_name, var_component=var_rds)

    except yaml.YAMLError as exc:
        print(exc)
    except Exception as inst:
        print(inst)
