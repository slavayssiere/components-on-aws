# EKS Test

## Pré requis

### Récupération de credentials AWS

Script de connexion à AWS.

A remplacer :

- AWS_ACCESS_KEY_ID=***
- AWS_SECRET_ACCESS_KEY=***
- USERNAME=terraform
- ACCOUNT_ARN=arn:aws:iam::***
- TARGET_ACCOUNT_ARN=arn:aws:iam::***

```language-bash
#!/usr/bin/env bash
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_STS AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SECURITY_TOKEN AWS_SESSION_TOKEN
export USERNAME=terraform
export AWS_DEFAULT_REGION=eu-west-1
export AWS_ACCESS_KEY_ID=***
export AWS_SECRET_ACCESS_KEY=***
export ROLE_NAME=EC2TerraformRole
export ACCOUNT_ARN=arn:aws:iam::***
export TARGET_ACCOUNT_ARN=arn:aws:iam::***
export MFA_CODE=$1
AWS_STS=($(aws sts assume-role --role-arn $TARGET_ACCOUNT_ARN:role/$ROLE_NAME --serial-number $ACCOUNT_ARN:mfa/$USERNAME --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken,Credentials.Expiration]' --output text --token-code $MFA_CODE --role-session-name $ROLE_NAME))
export AWS_ACCESS_KEY_ID=${AWS_STS[0]}
export AWS_SECRET_ACCESS_KEY=${AWS_STS[1]}
export AWS_SECURITY_TOKEN=${AWS_STS[2]}
export AWS_SESSION_TOKEN=${AWS_STS[2]}
```

Utiliser le script ainsi :

```language-bash
source ./connect.sh (Ecrire le MFA ici)
```

## IaC

Pour lancer la création d'une plateforme :

```language-bash
./apply.py PLATEFORM_YAML_PATH
```

Pour supprimer une plateforme :

```language-bash
./destroy.sh PLATEFORM_YAML_PATH
```

## Documentation

All docs on [slavayssiere.github.io/components-on-aws](https://slavayssiere.github.io/components-on-aws/)

## To do

- add default app
