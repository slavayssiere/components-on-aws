#!/usr/bin/env python3

import yaml
import sys 

class YamlCheckError(Exception):
    def __init__(self, block, message):
        self.block = block
        self.message = message

def check_base(plateform):
    if 'name' not in plateform:
        raise YamlCheckError('base', 'please add name of plateform')
    if 'type' not in plateform:
        raise YamlCheckError('base', 'please add type of plateform')
    if 'account' not in plateform:
        raise YamlCheckError('base', 'please add aws account of plateform')
    if 'region' not in plateform:
        raise YamlCheckError('base', 'please add aws region of plateform')
    if 'public-dns' not in plateform:
        raise YamlCheckError('base', 'please add public-dns SOA of plateform')

def check_network(plateform):
    pass

def check_eks(plateform):
    # dependencies test
    if 'component-network' not in plateform:
        raise YamlCheckError('eks', 'component-network is mandatory')
    
    # component struct test
    component = plateform['component-eks']
    if 'network-type' not in component:
        raise YamlCheckError('eks', 'network-type is missing')
    pass

def check_bastion(plateform):
    if 'component-network' not in plateform:
        raise YamlCheckError('bastion', 'component-network is mandatory')
    pass

def check_rds(plateform):
    if 'component-network' not in plateform:
        raise YamlCheckError('rds', 'component-network is mandatory')
    if not isinstance(plateform['component-rds'], list):
        raise YamlCheckError('rds', 'component-rds should be a list')
    pass

def check_web(plateform):
    if 'component-network' not in plateform:
        raise YamlCheckError('web', 'component-network is mandatory')
    if not isinstance(plateform['component-web'], list):
        raise YamlCheckError('web', 'component-web should be a list')
    pass

def check_yaml(plateform):
    # component base check
    check_base(plateform)

    if 'component-network' in plateform:
        check_network(plateform)
     
    if 'component-eks' in plateform:   
        check_eks(plateform)

    if 'component-bastion' in plateform:     
        check_bastion(plateform)

    if 'component-rds' in plateform: 
        check_rds(plateform)

    if 'component-web' in plateform: 
        check_web(plateform)

