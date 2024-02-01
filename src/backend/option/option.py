import json

def lambda_handler(event, context):
    print(event)

    origin = "*"
    if event["headers"]["origin"]:
        origin = event["headers"]["origin"]
    
    print(f"Request from: {origin}")

    response = {}
    response['statusCode'] = 200
    response['headers'] = {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': origin,
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': "GET,POST,OPTION"
    }
    response['body'] = json.dumps({'msg' : "Hello from auth lambda"})