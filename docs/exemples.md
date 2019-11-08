# Exemples

## EKS

Ceci est la structure minimal pour lancer un EKS.

```yaml
name: calico
type: dev
account: '549637939820'
region: eu-west-1
public-dns: 'aws-wescale.slavayssiere.fr.'
component_network:
  enabled: true
component_eks:
  enabled: true
  network-type: calico
```

## Web application

Ceci est la structure minimal pour lancer un ALB+ASG.

```yaml
name: web-app
type: dev
account: '549637939820'
region: eu-west-1
public-dns: 'aws-wescale.slavayssiere.fr.'
component_network:
  enabled: true
applications:
  - name: mon-app
    composant: component_web
    ami-name: mon-app-*
    port: 80
    health-check: '/'
```

## RDS

Ceci est la structure minimal pour lancer un RDS.

```yaml
name: web-app
type: dev
account: '549637939820'
region: eu-west-1
public-dns: 'aws-wescale.slavayssiere.fr.'
component_network:
  enabled: true
component_rds:
  - name: app-cal-1
```

## Observability

Ceci est la structure minimal pour instancier l'observability.

```yaml
name: web-app
type: dev
account: '549637939820'
region: eu-west-1
public-dns: 'aws-wescale.slavayssiere.fr.'
component_network:
  enabled: true
component_observability:
  tracing: enabled
  grafana: enabled
```
