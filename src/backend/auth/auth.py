import json
import boto3
import os
import requests

from botocore.exceptions import ClientError
from urllib.parse import urlencode


SECRET_NAME = os.environ.get("SECRET_NAME", "blank")
REGION = os.environ.get("REGION", "blank")
TOKEN_URL = os.environ.get("TOKEN_URL", "blank")
SPOTIFY_CREDENTIALS = {}
print("Hello from outside handler")

# Obtain spoitify credentials from secrets manager
def get_secret():
    print(f"Retriving secret values from {SECRET_NAME}")
    secrets_client = boto3.client('secretsmanager' )

    try:
        get_secret_value_response = secrets_client.get_secret_value(
            SecretId=SECRET_NAME
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("The requested secret " + SECRET_NAME + " was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("The request had invalid params:", e)
        elif e.response['Error']['Code'] == 'DecryptionFailure':
            print("The requested secret can't be decrypted using the provided KMS key:", e)
        elif e.response['Error']['Code'] == 'InternalServiceError':
            print("An error occurred on service side:", e)
    else:
        # Secrets Manager decrypts the secret value using the associated KMS CMK
        # Depending on whether the secret was a string or binary, only one of these fields will be populated
        if 'SecretString' in get_secret_value_response:
            text_secret_data = eval(get_secret_value_response['SecretString'])
            SPOTIFY_CREDENTIALS["CLIENT_ID"] = text_secret_data["CLIENT_ID"]
            SPOTIFY_CREDENTIALS["CLIENT_SECRET"] = text_secret_data["CLIENT_SECRET"]
            SPOTIFY_CREDENTIALS["REDIRECT_URL"] = text_secret_data["REDIRECT_URL"]
        else:
            binary_secret_data = get_secret_value_response['SecretBinary']

def get_access_token(authorization_code):
    token_data = {
        'grant_type': 'authorization_code',
        'code': authorization_code,
        'redirect_uri': SPOTIFY_CREDENTIALS["REDIRECT_URL"],
    }

    # Headers for authentication
    token_headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
    }

    # Base64-encoded string of client_id:client_secret
    auth_string = f'{SPOTIFY_CREDENTIALS["CLIENT_ID"]}:{SPOTIFY_CREDENTIALS["CLIENT_SECRET"]}'
    encoded_auth = auth_string.encode('utf-8').hex()

    token_headers['Authorization'] = f'Basic {encoded_auth}'

    try:
        # Make a POST request to Spotify for the access token
        response = requests.post(TOKEN_URL, data=urlencode(token_data), headers=token_headers)
        response_data = response.json()

        # Extract the access token
        access_token = response_data.get('access_token')

        return {
            'statusCode': 200,
            'body': json.dumps({'accessToken': access_token})
        }
    except Exception as e:
        print(f'Error getting access token: {e}')
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal Server Error'})
        }

def lambda_handler(event, context):
    print(event)
    # body = json.loads(event['body'])
    # authorization_code = body['authorization_code']
    # print(authorization_code)

    response = {}
    response['statusCode'] = 200
    response['headers'] = {
        'Content-Type': 'application/json; charset=utf-8'
    }
    response['body'] = json.dumps({'msg' : "Hello from auth lambda"})

    return response