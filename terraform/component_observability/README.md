# component observability

## definition

Créer les éléments d'observabilité de l'infratructure

## dependances

- network
- component Web

## elements

- monitoring
  - un node exporter par EC2 (inclus node EKS)
  - un prometheus (dans un ASG)
    - découverte via ec2_sd_config (https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ec2_sd_config)
- alerting
  - AlertManager (dans un ASG)
  - vers sns
- tracing
  - jaeger
- Grafana sur EC2, branché par défaut sur
  - le prometheus sur EC2

à faire

- monitoring
  - cloudwatch-exporter pour les services managés (TODO)
  - pushGateway pour les métriques lambdas métiers
  - add Thanos backend (or other remote_write)
- alerting
  - to SES
- logging
  - fluentd par EC2 (pour les node EKS uniquement les logs EC2)
    - => dans bucket s3
    - => dans l'ES managé
- tracing
  - vers ES managé (TODO)
  - jaeger-operator dans EKS
- Grafana sur EC2, branché par défaut sur
  - prometheus de EKS
  - grafana de EKS

## struct

mandatory:

```yaml
component_observability:
  tracing: enabled
  grafana: enabled
  prometheus: enabled
  alertmanager:
    list_emails:
      - sebastien.lavayssiere@wescale.fr
      - sebastien.lavayssiere@gmail.com
```

optionnal:

```yaml
component_observability:
  ips_whitelist:
    - '195.137.181.15/32'
    - '195.137.181.130/32'
  ami-account: 549637939820
```
