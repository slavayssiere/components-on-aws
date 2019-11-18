#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.def_component import Component
from iac.yaml_check_error import YamlCheckError
from iac.aws_object import get_secret_value, get_parameter_value

class ComponentRDS(Component):

  def define_var(self):
    pass

  def apply(self):
    if 'component_rds' in self.plateform:
      print("apply rds...")
      for rds in self.lateform['component_rds']:
        self.compute_var(rds, self.create)

  def destroy(self):
    if 'component_rds' in self.plateform:
      print("apply rds...")
      for rds in self.plateform['component_rds']:
        self.compute_var(rds, self.delete)

  def compute_var(self, rds, func):
    rds_plateform_name = self.plateform_name + "-" + rds['name']
    snapshot_parameter_name = 'snapshot-rds-' + self.plateform_name+"-" + rds['name']
    snapshot_enable = False
    snapshot_name = ''

    is_prod = False
    if self.plateform['type'] == 'prod':
      is_prod = True

    if 'snapshot_name' in rds:
      snapshot_enable = True
      snapshot_name = rds['snapshot_name']
      snapshot_id = get_parameter_value(snapshot_parameter_name)

      print("current snapshot_id: " + snapshot_id)

    print("Create " + rds_plateform_name + " rds")
    var={
      'bucket_component_state': self.bucket_component_state,
      'workspace-network': self.plateform_name,
      'dns-name': rds['name'],
      'deletion_protection': is_prod,
      'multi_az': is_prod,
      'username': rds['username'],
      'password': get_secret_value(rds_plateform_name),
      'snapshot_enable': snapshot_enable,
      'snapshot_name': snapshot_name,
      'engine': rds['engine'],
      'engine_version': rds['engine_version'],
      'snapshot_rds_paramater_name': snapshot_parameter_name
    }
    func(
      working_dir='../terraform/component_rds', 
      plateform_name=rds_plateform_name, 
      var_component=var
    )

  def check(self):
    if 'component_network' not in self.plateform:
      raise YamlCheckError('rds', 'component_network is mandatory')
    if not isinstance(self.plateform['component_rds'], list):
      raise YamlCheckError('rds', 'component_rds should be a list')
    pass

