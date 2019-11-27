#!/bin/bash

cp ../terraform/component_base/README.md tmp/base.md

vuepress build . --dest ../docs

rm -f tmp/*