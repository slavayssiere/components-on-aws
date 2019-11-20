#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from iac.yaml_check_error import YamlCheckError
from terraform.component_network.functions import ComponentNetwork

class ComponentWeb(Component):

  blocname = "component_web"
  component_name = "web"

  def define_var(self):
    pass
  
  def get_workspace(self, web_name):
    return self.plateform_name + "-web-" + web_name

  def compute_var(self, web, func):

    network = ComponentNetwork(self.plateform)

    bastion_enable = False
    if 'component_bastion' in self.plateform:
      bastion_enable = True

    if 'health-check-port' not in web:
      health_check_port = web['port']
    else:
      health_check_port = web['health-check-port']

    ami_account = self.plateform['account']
    if 'ami-account' in web:
      ami_account = web['ami-account']

    user_data = ''
    if 'user-data' in web:
      user_data = web['user-data']

    if 'attach_cw_ro' not in web:
      web['attach_cw_ro'] = False

    if 'attach_ec2_ro' not in web:
      web['attach_ec2_ro'] = False

    if 'attach_sns_pub' not in web:
      web['attach_sns_pub'] = False

    if 'enable_private_alb' not in web:
      web['enable_private_alb'] = False

    if 'enable_public_alb' not in web:
      web['enable_public_alb'] = True

    if 'ips_whitelist' not in web:
      web['ips_whitelist'] = ["0.0.0.0/0"]

    if 'enable_cognito' not in web:
      web['cognito_list']=[]
    else:
      web['cognito_list']=[1]

    var={
      'bucket_component_state': self.bucket_component_state,
      'workspace-network': network.get_workspace(),
      'dns-name': web['name'],
      'ami-name': web['ami-name'],
      'ami-account': ami_account,
      'user-data': user_data,
      'port': web['port'],
      'health_check': web['health-check'],
      'health_check_port': health_check_port,
      'efs_enable': web['efs-enable'],
      'node-count': web['node-count'],
      'min-node-count': web['min-node-count'],
      'max-node-count': web['max-node-count'],
      'bastion_enable': bastion_enable,
      'attach_cw_ro': web['attach_cw_ro'],
      'attach_ec2_ro': web['attach_ec2_ro'],
      'attach_sns_pub': web['attach_sns_pub'],
      'ips_whitelist': web['ips_whitelist'],
      'cognito_list': web['cognito_list'],
      'enable_private_alb': web['enable_private_alb'],
      'enable_public_alb': web['enable_public_alb']
    }
    func(
      working_dir='../terraform/component_web', 
      workspace_name=self.get_workspace(web['name']), 
      var_component=var
    )


  def apply(self):
    if self.blocname not in self.plateform:
      return

    for web in self.plateform['component_web']:
      print("Create web component: " + web['name'])
      self.compute_var(web, self.create)
      
  def destroy(self):
    if self.blocname not in self.plateform:
      return

    for web in self.plateform['component_web']:
      print("Create web component: " + web['name'])
      self.compute_var(web, self.delete)

  def check(self):
    if 'component_network' not in self.plateform:
        raise YamlCheckError('web', 'component_network is mandatory')
    if not isinstance(self.plateform['component_web'], list):
        raise YamlCheckError('web', 'component_web should be a list')
