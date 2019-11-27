# component eks

## definition

Permet d'avoir un kubernetes utilisable

## dependances

est dépendant de component-network

## elements

- EKS avec
  - les masters managés
  - un node pool de compute
  - un node pool de ...
  - installation / confirguration de Calico (ou cilium)
- deux ingress controllers "traefik"
  - un pour les flux public
  - un pour les flux d'aministration

à rajouter:

- un backend de stockage Rook (ceph) sur un NodePool de i3 (stockage des PVC en multi-az)
- cluster-autoscaler
- externalDNS
- kube2iam ou kiam ou service EKS

## struct

mandatory:

```yaml
component_eks:
```

optionnal:

```yaml
component_eks:
```
