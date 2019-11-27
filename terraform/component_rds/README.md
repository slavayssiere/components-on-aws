# component rds

## definition

Create a rds instance from scratch or from snapshot
Only for PG and MySQL

## dependances

- network

## elements

- rds
- subnet group
- sg
- secret
- and secret-path in paramater store

à faire

- lambda rotation secret

## struct

WARNING: this component is a list !

mandatory:

```yaml
component_rds:
  - name: db
    username: 'PgAdmin'
    engine: 'postgres'
    engine_version: '9.6'
```

optionnal:

```yaml
component_rds:
  - snapshot_name: 'arn:aws:rds:eu-west-1:200066602731:snapshot:just-for-test'
```
