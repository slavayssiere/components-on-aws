#!/usr/bin/env python3

from functions_terraform import create_component, delete_component
from yaml_check import check_yaml, YamlCheckError
from aws_object import get_secret_value
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
        if plateform['type'] == "prod":
            is_prod = True
        
        account = plateform['account']
        plateform_name = plateform['name']

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
            create_component(working_dir='../terraform/component-bastion', plateform_name=plateform_name, var_component={'enable_eks': True})
            ## launch eks script
            print("Post Apply script execution...")
            subprocess.call(["../terraform/component-eks/apply.sh", plateform_name, network_type, account])
            create_component(working_dir='../terraform/component-eks/component-alb', plateform_name=plateform_name, var_component={})

            # we do not need a bastion
            if 'component-bastion' in plateform:
                print("do not delete bastion")
            else:
                delete_component(working_dir='../terraform/component-bastion', plateform_name=plateform_name, var_component={})

        if 'component-bastion' in plateform:
            if 'component-eks' in plateform:
                print("bastion created")
            else:
                create_component(working_dir='../terraform/component-bastion', plateform_name=plateform_name, var_component={'enable_eks': False})

        if 'component-rds' in plateform:
            for rds in plateform['component-rds']:
                rds_plateform_name = plateform_name + "-" + rds['name']
                print("Create " + rds_plateform_name + " rds")
                var_rds={
                    'workspace-network': plateform_name,
                    'dns-name': rds['name'],
                    'deletion_protection': is_prod,
                    'multi_az': is_prod,
                    'password': get_secret_value(rds_plateform_name)
                }
                create_component(working_dir='../terraform/component-rds', plateform_name=rds_plateform_name, var_component=var_rds)

        if 'component-web' in plateform:
            for web in plateform['component-web']:
                web_plateform_name = plateform_name + "-" + web['name']
                print("Create " + web_plateform_name + " web")
                if 'health-check-port' not in web:
                    health_check_port = web['port']
                else:
                    health_check_port = web['health-check-port']

                var_web={
                    'workspace-network': plateform_name,
                    'dns-name': web['name'],
                    'ami': web['ami'],
                    'user-data': web['user-data'],
                    'port': web['port'],
                    'health_check': web['health-check'],
                    'health_check_port': health_check_port
                }
                create_component(working_dir='../terraform/component-web', plateform_name=web_plateform_name, var_component=var_web)

        if 'component-observability' in plateform:
            if 'grafana' in plateform['component-observability']:
                grafana_plateform_name=plateform_name+"-grafana"
                var_web={
                    'workspace-network': plateform_name,
                    'dns-name': 'grafana',
                    'ami': 'ami-0cd35dee04b2dc36c',
                    'port': '3000',
                    'health_check': '/api/health',
                    'health_check_port': '3000'
                }
                create_component(working_dir='../terraform/component-web', plateform_name=grafana_plateform_name, var_component=var_web)
            if 'tracing' in plateform['component-observability']:
                grafana_plateform_name=plateform_name+"-tracing"
                var_web={
                    'workspace-network': plateform_name,
                    'dns-name': 'tracing',
                    'ami': 'ami-',
                    'port': '16686',
                    'health_check': '/',
                    'health_check_port': '16687'
                }
                create_component(working_dir='../terraform/component-web', plateform_name=grafana_plateform_name, var_component=var_web)

    except yaml.YAMLError as exc:
        print(exc)
    except YamlCheckError as yce:
        print("Yaml Check error in bloc: " + yce.block)
        print("Yaml Check error message: " + yce.message)
    except Exception as inst:
        print(inst)
    else:
        print("Plateform " + plateform_name + " is running")
