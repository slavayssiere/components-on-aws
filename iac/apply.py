#!/usr/bin/env python3

import sys
sys.path.append("..")

from yaml_check import check_yaml
from yaml_check_error import YamlCheckError
from aws_object import get_secret_value, is_always_connected
from terraform.component_base.functions import apply as apply_base
from terraform.component_network.functions import apply as apply_network
from terraform.component_bastion.functions import apply as apply_bastion
from terraform.component_bastion.functions import destroy as destroy_bastion
from terraform.component_eks.functions import apply as apply_eks
from terraform.component_rds.functions import apply as apply_rds
from terraform.component_web.functions import apply as apply_web
from terraform.component_observability.functions import apply as apply_observability
from terraform.component_link.functions import apply as apply_link

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
        print("check yaml...")
        check_yaml(plateform)

        # check if credential is always available
        print("check is always connected...")
        is_always_connected()

        bucket_component_state = plateform['bucket-component-state']
        print("bucket used is: " + bucket_component_state)

        # to allow multi_az, deletion_protection and others
        is_prod = False
        if plateform['type'] == "prod":
            is_prod = True
        
        account = plateform['account']
        plateform_name = plateform['name']

        print("Will create plateform: " + plateform_name + " in account:" + account)

        ## component base
        print("apply base...")
        apply_base(plateform)
        
        ## component network
        if 'component_network' in plateform:
            print("apply network...")
            apply_network(plateform)

        ## component eks
        if 'component_eks' in plateform:
            print("apply eks...")
            apply_eks(bucket_component_state, plateform)

        if 'component_bastion' in plateform:
            if 'component_eks' in plateform:
                print("bastion already created")
            else:
                print("apply bastion...")
                apply_bastion(bucket_component_state, plateform)
        else:
            destroy_bastion(bucket_component_state, plateform)

        if 'component_rds' in plateform:
            print("apply rds...")
            for rds in plateform['component_rds']:
                apply_rds(bucket_component_state, rds, plateform['name'], is_prod)

        if 'component_web' in plateform:
            print("apply web...")
            for web in plateform['component_web']:
                apply_web(bucket_component_state, web, plateform['name'], plateform['account'])

        if 'component_observability' in plateform:
            print("apply component_observability...")
            apply_observability(bucket_component_state, plateform)

        print("search link between component for security-group opening")
        apply_link(plateform)
            
    except yaml.YAMLError as exc:
        print(exc)
    except YamlCheckError as yce:
        print("Yaml Check error in bloc: " + yce.block)
        print("Yaml Check error message: " + yce.message)
    except Exception as inst:
        print(inst)
    else:
        print("Plateform " + plateform_name + " is running")
