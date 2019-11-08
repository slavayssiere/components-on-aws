#!/usr/bin/env python3

import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.insert(1, '../..')

from iac.functions_terraform import create_component, delete_component

def apply(plateform):
  create_component(working_dir='../terraform/component_network', plateform_name=plateform['name'], var_component={})