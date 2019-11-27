# component network

## definition

Permet de créer l'ensemble des éléments du réseau

## elements for component-network

- VPC
- subnet
- subnet group
- routes table
- nat gateway
- egress only internet gateway
- route53 private zone

## struct

mandatory:

```yaml
component_network:
  private-dns: 'slavayssiere.accor.'
```

optional:

```yaml
component_network:
  nat-gateway: true
```
