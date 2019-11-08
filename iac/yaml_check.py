#!/usr/bin/env python3

from terraform.component_base.functions import check as check_base
from terraform.component_network.functions import check as check_network
from terraform.component_bastion.functions import check as check_bastion
from terraform.component_eks.functions import check as check_eks
from terraform.component_rds.functions import check as check_rds
from terraform.component_web.functions import check as check_web

import yaml

class YamlCheckError(Exception):
    def __init__(self, block, message):
        self.block = block
        self.message = message

def check_yaml(plateform):
    # component base check
    check_base(plateform)

    if 'component_network' in plateform:
        check_network(plateform)
     
    if 'component_eks' in plateform:   
        check_eks(plateform)

    if 'component_bastion' in plateform:     
        check_bastion(plateform)

    if 'component_rds' in plateform: 
        check_rds(plateform)

    if 'component_web' in plateform: 
        check_web(plateform)

