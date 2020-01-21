#!/bin/bash

rm -Rf ../docs

cp ../terraform/component_base/README.md tmp/base.md
cp ../terraform/component_bastion/README.md tmp/bastion.md
cp ../terraform/component_eks/README.md tmp/eks.md
cp ../terraform/component_link/README.md tmp/link.md
cp ../terraform/component_network/README.md tmp/network.md
cp ../terraform/component_observability/README.md tmp/observability.md
cp ../terraform/component_rds/README.md tmp/rds.md
cp ../terraform/component_web/README.md tmp/web.md

vuepress build . --dest ../docs

rm -f tmp/*.md