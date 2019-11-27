# component bastion

## definition

## dependencies

- network

## elements

- EC2 instance (instance profile)
- route53 dns name
- SG with white list ips

## struct

mandatory:

```yaml
component_bastion:
  enabled: true
```

optionnal:

```yaml
component_bastion:
  ips_whitelist:
    - '195.137.181.15/32'
    - '195.137.181.130/32'
```
