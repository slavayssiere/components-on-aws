# composant base

## definition

Ce composent est necessaire pour créer une plateforme

## elements

- public route53 SOA "$plateform.accor.net" (to be defined)
- activate CWL for api gateway
- aws cognito pour la gestion des utilisateurs "admin" (sauf si ping identity)
  - la liste des utilisateurs est fournis au component via le manifest
- initie le chatops

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
