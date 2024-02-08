import boto3
import json
import os


def lambda_handler(event, context):
    print(event)
    # body = json.loads(event['body'])
    # key = body['key']

    # url = generate_presigned_url(key)
    response = {}
    response['statusCode'] = 200
    response['headers'] = {
        'Content-Type': 'application/json'
    }
    response['body'] = {'msg' : "Hello from mosaify lambda"}

    return response