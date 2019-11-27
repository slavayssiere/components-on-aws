#!/usr/bin/env python3

import sys
import subprocess
import yaml
import time

sys.path.append("..")

# import objects
from iac.yaml_check_error import YamlCheckError
from iac.aws_object import is_always_connected
from terraform.component_base.functions import ComponentBase
from terraform.component_network.functions import ComponentNetwork
from terraform.component_bastion.functions import ComponentBastion
from terraform.component_eks.functions import ComponentEKS
from terraform.component_rds.functions import ComponentRDS
from terraform.component_web.functions import ComponentWeb
from terraform.component_observability.functions import ComponentObservability
from terraform.component_link.functions import ComponentLink

# import YAML librairie
try:
  from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
  from yaml import Loader, Dumper

# we need yaml in path
if len(sys.argv) > 1:
  name_file = sys.argv[1]
  print("create from file: " + name_file)
else:
  sys.exit()

with open(name_file, 'r') as stream:
  try:
    plateform=yaml.load(stream, Loader=Loader)
    
    start_time = time.time()

    print("Load components...")
    base = ComponentBase(plateform)
    bastion = ComponentBastion(plateform)
    eks = ComponentEKS(plateform)
    network = ComponentNetwork(plateform)
    web = ComponentWeb(plateform)
    link = ComponentLink(plateform)
    obs = ComponentObservability(plateform)
    rds = ComponentRDS(plateform)

    load_finish_time = time.time()

    # check if credential is always available
    print("check is always connected...")
    is_always_connected()

    print("Will create plateform: " + plateform['name'] + " in account:" + plateform['account'])
    base.apply()
    base_finish_time = time.time()

    network.apply()
    network_finish_time = time.time()

    eks.apply()
    eks_finish_time = time.time()

    bastion.apply()
    bastion_finish_time = time.time()

    web.apply()
    web_finish_time = time.time()

    obs.apply()
    obs_finish_time = time.time()

    rds.apply()
    rds_finish_time = time.time()
    
    link.apply()
    link_finish_time = time.time()

    print("Total time: " + str(time.time() - start_time))
    print("Base time: " + str(base_finish_time - start_time))
    print("Network time: " + str(network_finish_time - start_time))
    print("EKS time: " + str(eks_finish_time - start_time))
    print("Web time: " + str(web_finish_time - start_time))
    print("Observability time: " + str(obs_finish_time - start_time))
    print("RDS time: " + str(rds_finish_time - start_time))
    print("Link time: " + str(link_finish_time - start_time))
          
  except yaml.YAMLError as exc:
    print(exc)
  except YamlCheckError as yce:
    print("Yaml Check error in bloc: " + yce.block)
    print("Yaml Check error message: " + yce.message)
  except Exception as inst:
    print(inst)
  else:
    print("Plateform " + plateform['name'] + " is running")
