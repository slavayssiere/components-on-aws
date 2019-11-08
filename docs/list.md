# Components list

Voici une liste des composants principaux:

- component-base: c'est le composant minimum dans une plateforme
- component-network: permet de créer le networking
- component-kubernetes: contient le cluster k8s, sa gestion du réseau et les éléments indispensables
- component-observability-infra: permet d'observer l'infra
- component-observability-apps: permet d'observer les apps
- component-serverless-enable: active les élements permettant de profiter du serverless
- component-grafana-eks: pour installer un grafana dans eks
- component-batch: pour lancer un container

## Components definition

### component-base

Ce composent est necessaire pour créer une plateforme

#### ownership for component-base

- team solution

#### elements for component-base

- public route53 SOA "$plateform.accor.net" (to be defined)
- activate CWL for api gateway
- aws cognito pour la gestion des utilisateurs "admin" (sauf si ping identity)
  - la liste des utilisateurs est fournis au component via le manifest
- initie le chatops

### component-network

Permet de créer l'ensemble des éléments du réseau

#### ownership for component-network

- team réseau
- temps ops

#### elements for component-network

- VPC
- subnet
- subnet group
- routes table
- nat gateway
- egress only internet gateway
- route53 private zone

### component-kubernetes

Permet d'avoir un kubernetes utilisable

#### Dépendance de component-kubernetes

est dépendant de component-network

#### ownership for component-kubernetes

- team solution

#### elements for component-kubernetes

- EKS avec
  - les masters managés
  - un node pool de compute
  - un node pool de ...
  - installation / confirguration de Calico (ou cilium)
- deux ingress controllers "traefik"
  - un pour les flux public
  - un pour les flux d'aministration
- un backend de stockage Rook (ceph) sur un NodePool de i3 (stockage des PVC en multi-az)
- cluster-autoscaler
- externalDNS
- kube2iam ou kiam ou service EKS

### component-observability-infra

Créer les éléments d'observabilité de l'infratructure

#### Dépendance de component-observability-infra

est dépendant de component-network

#### ownership for component-observability-infra

- team solution

#### elements for component-observability-infra

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

### component-observability-apps

Map les métriques applicatives

#### Dépendance de component-observability-apps

est dépendant de "component-observability-infra"

#### ownership for component-observability-apps

- team solution

#### elements for component-observability-apps

- monitoring
  - dans EKS
    - prometheus-operator
      - un prometheus par namespace
  - dans Lambda
  - dans EC2
- alerting
  - utiliser l'AlertManager sur vm ec2
- logging
  - fluentd pour les logs apps
    - => dans bucket s3
    - => dans l'ES managé
- tracing
  - vers ES managé
  - dans EKS
    - jaeger-operator dans EKS

### component-serverless-enable

Gère les dépendances des applictions lambda

#### dependances for component-serverless-enable

est dépendant de component-network

#### ownership for component-serverless-enable

- team solution

#### elements for component-serverless-enable

- configuration d'api-gateway
- lambda d'authentification
- ...

### component-grafana-eks

Ajout un grafana pour un namespace dans EKS

#### dependances for component-grafana-eks

- component-kubernetes
- component-observability-apps
- component du projet

#### ownership for component-grafana-eks

- team solution

#### elements for component-grafana-eks

- helm chart grafana
  - oauth pluggé sur Cognito (ou idp ops)

### To be defined component

les composants à définir:

- ...

## Composants applicatifs

Un composant peut également être une application
cf: https://www.12factor.net/fr/
cf: https://blog.wescale.fr/2019/08/22/la-nouvelle-stack-du-developpeur-backend-cloud-native/

## Other

https://Ext2-R1-119
