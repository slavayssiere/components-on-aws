import boto3

def generate_secret():
  client = boto3.client('secretsmanager')
  response = client.get_random_password(
    PasswordLength=32,
    ExcludeNumbers=False,
    ExcludePunctuation=True,
    ExcludeUppercase=False,
    ExcludeLowercase=False,
    IncludeSpace=False,
    RequireEachIncludedType=False
  )
  return response['RandomPassword']

def get_secret_value(rds_name):

  secret_name = get_parameter_value("rds-admin-secret-path-" + rds_name)

  if len(secret_name) == 0:
    return generate_secret()

  client = boto3.client('secretsmanager')
  try:
    response = client.describe_secret(
      SecretId=secret_name
    )
  except client.exceptions.ResourceNotFoundException:
    print('Generate new secret')
    return generate_secret()
  else:
    print('Get secret from SecretManager')
    response = client.get_secret_value(
      SecretId='rds-admin-secret-'+rds_name
    )
    return response['SecretString']

def get_parameter_value(parameter_name):
  client = boto3.client('ssm')
  try:
    response = client.get_parameter(
      Name=parameter_name
    )
  except client.exceptions.ParameterNotFound:
    print(parameter_name + ' not found')
    return ''
  else:
    return response['Parameter']['Value']

def is_always_connected():
  client = boto3.client('sts')
  client.get_caller_identity()