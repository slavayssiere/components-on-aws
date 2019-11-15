#!/usr/bin/env python3
import sys
sys.path.append("..")

from terraform.component_web.functions import destroy as destroy_web
from terraform.component_rds.functions import destroy as destroy_rds
from terraform.component_eks.functions import destroy as destroy_eks
from terraform.component_base.functions import destroy as destroy_base
from terraform.component_network.functions import destroy as destroy_network
from terraform.component_bastion.functions import destroy as destroy_bastion
from terraform.component_link.functions import destroy as destroy_link
from terraform.component_observability.functions import destroy as destroy_observability
from yaml_check import check_yaml
from yaml_check_error import YamlCheckError
import subprocess
import yaml
import sys 

if len(sys.argv) > 1:
  name_file = sys.argv[1]
  print("create from file: " + name_file)
else:
  name_file = input("Nom du fichier: ")

try:
  from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
  from yaml import Loader, Dumper

with open(name_file, 'r') as stream:
  try:
    plateform=yaml.load(stream, Loader=Loader)

    # validate YAML
    check_yaml(plateform)

    bucket_component_state = plateform['bucket-component-state']

    # to allow multi_az, deletion_protection and others
    is_prod = False
    account = plateform['account']
    plateform_name = plateform['name']

    print("Will delete plateform: " + plateform_name + " in account:" + account)

    destroy_link(plateform)

    if 'component_observability' in plateform:
      print("destroy component_observability...")
      destroy_observability(bucket_component_state, plateform)

    if 'component_rds' in plateform:
      print("delete rds")
      for rds in plateform['component_rds']:
        destroy_rds(bucket_component_state, rds, plateform['name'], False)

    if 'component_web' in plateform:
      print("delete web")
      for web in plateform['component_web']:
        destroy_web(bucket_component_state, web, plateform['name'], plateform['account'])

    if 'component_bastion' in plateform:
      print("delete bastion")
      destroy_bastion(bucket_component_state, plateform)

    ## component eks
    if 'component_eks' in plateform:
      destroy_eks(bucket_component_state, plateform)

    ## component network
    if 'component_network' in plateform:
      print("delete network")
      destroy_network(plateform)

    ## component base
    print("delete base")
    destroy_base(plateform)

  except yaml.YAMLError as exc:
      print(exc)
  except Exception as inst:
      print(inst)