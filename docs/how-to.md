# Explication

L'approche composant permet de mettre à disposition aux différentes équipes de développement des éléments d'infrastructure facilement instanciables et approvés.

Lors de la création d'une plateforme l'utilisateur créera un fichier permettant l'assemblage de ces éléments.

Un document exemple de ce manifest de création de plateform.

```language-yaml
name: $plateform
type: (prd || oat || dev)
component-base:
  enabled: true
  some: other
component-network:
  enabled: true
  cidr-vpc: 10.1.0.0/16
  some: other
component-k8s:
  enabled: true
  cidr-calico: 10.2.0.0/16
applications:
  - component-project-a:
      enabled: true
  - component-project-b:
      enabled: true
      some: key
      some: value
...
```

NOTES:

- s'il n'est pas dans la liste un composant n'est pas instancié
- gestion des dépendances: TODO
