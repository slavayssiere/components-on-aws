# component observability

## definition

Créer les éléments d'observabilité de l'infratructure

## dependances

- network

## elements

- ES managé

- monitoring
  - un node exporter par EC2 (inclus node EKS)
  - cloudwatch-exporter pour les services managés
  - pushGateway pour les métriques lambdas métiers
  - un prometheus (dans un ASG)
    - découverte via ec2_sd_config (https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ec2_sd_config)
- alerting
  - AlertManager (dans un ASG)
- logging
  - fluentd par EC2 (pour les node EKS uniquement les logs EC2)
    - => dans bucket s3
    - => dans l'ES managé
- tracing
  - vers ES managé
  - jaeger-operator dans EKS

- Grafana sur EC2, branché par défaut sur
  - le prometheus sur EC2

## struct

mandatory:

```yaml
component_observability:
```

optionnal:

```yaml
component_observability:
```
