import boto3
import json
import os

BUCKET_NAME = os.environ.get("BUCKET_NAME", "blank")

"""
Generate a presigned Amazon S3 URL that can be used to download file
"""
def generate_presigned_url(key, expires_in=300):
    try:
        s3_client = boto3.client('s3')
        url = s3_client.generate_presigned_url(
            ClientMethod="put_object", Params={"Bucket": BUCKET_NAME, "Key": key}, ExpiresIn=expires_in
        )
        print(f"Got presigned URL: {url}")
    except Exception as e:
        print("ERROR generating presigned URL")
        print(e)
    return url

def lambda_handler(event, context):
    print(event)
    if type(event['body']) == str:
        body = json.loads(event['body'])

    else:
        body = event['body']

    key = body['key']

    url = generate_presigned_url(key)

    origin = "*"
    if "origin" in event["headers"]:
        origin = event["headers"]["origin"]
    
    response = {}
    response['statusCode'] = 200
    response['headers'] = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': origin
    }
    response['body'] = json.dumps({'url' : url})

    print(response)
    return response