# composant base

## definition

Ce composent est necessaire pour créer une plateforme

## elements

- public route53 SOA
- enable alerting for billing
- initialize ses

TODO:

- AWS tagging policy

## struct

mandatory:

```yaml
name: calico
type: dev
account: '549637939820'
bucket-component-state: 'wescale-slavayssiere-terraform'
billing-alert: 100
billing-email: sebastien.lavayssiere@wescale.fr
```

optional:

```yaml
region: eu-west-1
public-dns: 'aws-wescale.slavayssiere.fr.'
```
