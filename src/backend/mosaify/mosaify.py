import boto3
import json
import os
import tempfile
import numpy as np

from botocore.exceptions import ClientError

UPLOAD_BUCKET_NAME = os.environ.get('UPLOAD_BUCKET_NAME')
DOWNLOAD_BUCKET_NAME = os.environ.get('DOWNLOAD_BUCKET_NAME')

# Function downloads image from s3 and converts to numpy array
def download_image(key):
    try:
        print(f"Downloading {key} from {UPLOAD_BUCKET_NAME} bucket")
        # temp = tempfile.TemporaryFile()
        s3_client = boto3.client('s3')
        # s3_client.download_fileobj(UPLOAD_BUCKET_NAME, key, temp)
        # # temp.write(b'Hello world!')
        # temp.seek(0)

        # # convert tempfile to numpy array using load method
        # imageArr = np.fromfile(temp)
        # # close temp file
        # temp.close()

        response = s3_client.get_object(Bucket=UPLOAD_BUCKET_NAME, Key=key)
        metadata = response['Metadata']
        height = metadata['height']
        width = metadata['width']
        channels = 3
        # Download image file to a temporary file
        with tempfile.TemporaryFile() as temp:
            try:
                s3_client.download_fileobj(UPLOAD_BUCKET_NAME, key, temp)
                temp.seek(0)
                
                # Read the image data from the temporary file
                image_data = temp.read()
                imageArr = np.frombuffer(image_data, dtype=np.uint8)
                imageArr = imageArr.reshape((height, width, channels))
                
            except Exception as e:
                print(f"ERROR downloading {key} file object from {UPLOAD_BUCKET_NAME} bucket")
                raise e

        return imageArr

    except Exception as e:
        print(f"ERROR downloading {key} from {UPLOAD_BUCKET_NAME} bucket")
        raise e

def lambda_handler(event, context):
    print(event)
    # body = json.loads(event['body'])
    body = event['body']
    key = body['key']
    uris = body['uris']
    print(key)
    print(uris)

    imgArr = download_image(key)
    print(imgArr.shape)

    # height = imgArr.shape[0]
    # width = imgArr.shape[1]
    # print(width, height)
    # url = generate_presigned_url(key)
    response = {}
    response['statusCode'] = 200
    response['headers'] = {
        'Content-Type': 'application/json'
    }
    response['body'] = {'msg' : "Hello from mosaify lambda"}

    return response