#!/usr/bin/env python3
import sys
sys.path.append("..")

from aws_object import get_secret_value, is_always_connected
from terraform.component_base.functions import ComponentBase
from terraform.component_network.functions import ComponentNetwork
from terraform.component_bastion.functions import ComponentBastion
from terraform.component_eks.functions import ComponentEKS
from terraform.component_rds.functions import ComponentRDS
from terraform.component_web.functions import ComponentWeb
from terraform.component_observability.functions import ComponentObservability
from terraform.component_link.functions import ComponentLink
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

    base = ComponentBase(plateform)
    bastion = ComponentBastion(plateform)
    eks = ComponentEKS(plateform)
    network = ComponentNetwork(plateform)
    web = ComponentWeb(plateform)
    link = ComponentLink(plateform)
    obs = ComponentObservability(plateform)
    rds = ComponentRDS(plateform)

    print("Will delete plateform: " + plateform['name'] + " in account:" + plateform['account'])

    print("link destroy")
    link.destroy()
    print("obs destroy")
    obs.destroy()
    print("rds destroy")
    rds.destroy()
    print("web destroy")
    web.destroy()
    print("bastion destroy")
    bastion.destroy()
    print("eks destroy")
    eks.destroy()
    print("network destroy")
    network.destroy()
    print("base destroy")
    base.destroy()

  except yaml.YAMLError as exc:
    print(exc)
  except Exception as inst:
    print(inst)
  else:
    print(plateform['name'] + "is destroy")