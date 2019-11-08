#!/usr/bin/env python3

import yaml

class YamlCheckError(Exception):
    def __init__(self, block, message):
        self.block = block
        self.message = message
