# component web

## definition

create a service provide by LB internal or public

## dependances

- network

## elements

- asg
- sg
- instance profile
- alb / ilb (and target group)
- efs

## struct

WARNING: this component is a list !

mandatory:

```yaml
component_web:
  - name: backend
    ami-name: 'ec2-just-for-test-*'
    node-count: 1
    min-node-count: 1
    max-node-count: 3
    port: 8080
    health-check: '/'
```

optionnal:

```yaml
component_web:
  - ami-account: '200066602731'
    health-check-port: '8081'
    efs-enable: true
    link-rds: db
    user-data: |
      #!/bin/bash
      echo "hello world"
```
