#!/usr/bin/env python3

import sys
sys.path.append("..")

from yaml_check import check_yaml
from yaml_check_error import YamlCheckError
from aws_object import get_secret_value, is_always_connected
from terraform.component_base.functions import ComponentBase
from terraform.component_network.functions import ComponentNetwork
from terraform.component_bastion.functions import ComponentBastion
from terraform.component_eks.functions import ComponentEKS
from terraform.component_rds.functions import ComponentRDS
from terraform.component_web.functions import ComponentWeb
from terraform.component_observability.functions import ComponentObservability
from terraform.component_link.functions import ComponentLink

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

    base = ComponentBase(plateform)
    bastion = ComponentBastion(plateform)
    eks = ComponentEKS(plateform)
    network = ComponentNetwork(plateform)
    web = ComponentWeb(plateform)
    link = ComponentLink(plateform)
    obs = ComponentObservability(plateform)
    rds = ComponentRDS(plateform)

    # check if credential is always available
    print("check is always connected...")
    is_always_connected()

    print("Will create plateform: " + plateform['name'] + " in account:" + plateform['account'])

    base.apply()
    network.apply()
    eks.apply()
    bastion.apply()
    web.apply()
    obs.apply()
    rds.apply()

    print("search link between component for security-group opening")
    link.apply()
          
  except yaml.YAMLError as exc:
    print(exc)
  except YamlCheckError as yce:
    print("Yaml Check error in bloc: " + yce.block)
    print("Yaml Check error message: " + yce.message)
  except Exception as inst:
    print(inst)
  else:
    print("Plateform " + plateform['name'] + " is running")
