# component eks

## definition

Permet d'avoir un kubernetes utilisable

## dependances

- network
- bastion (éphémère à la création)

## elements

- EKS avec
  - les masters managés
  - un node pool de compute
  - installation / configuration de Calico (ou cilium)
- deux ingress controllers "traefik"
  - un pour les flux public
  - un pour les flux d'aministration
- deux alb pour accéder aux IC
- prometheus operator

à rajouter:

- un backend de stockage Rook (ceph) sur un NodePool de i3 (stockage des PVC en multi-az)
- cluster-autoscaler
- externalDNS
- kube2iam ou kiam ou service EKS

## struct

mandatory:

```yaml
component_eks:
  network-type: calico
```

optionnal:

```yaml
component_eks:
  link-rds:
    - app-cal-1
```
