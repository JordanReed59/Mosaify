import boto3
import json
import os
import tempfile
import cv2
import numpy as np

from botocore.exceptions import ClientError
from PIL import Image

UPLOAD_BUCKET_NAME = os.environ.get('UPLOAD_BUCKET_NAME')
DOWNLOAD_BUCKET_NAME = os.environ.get('DOWNLOAD_BUCKET_NAME')

# Function downloads image from s3 and converts to numpy array
def download_image(key):
    try:
        print(f"Downloading {key} from {UPLOAD_BUCKET_NAME} bucket")
        s3_client = boto3.client('s3')

        with tempfile.TemporaryFile() as temp:
            s3_client.download_fileobj(UPLOAD_BUCKET_NAME, key, temp)
            temp.seek(0)

            img = Image.open(temp)
        
            # Convert the image to a numpy array
            imageArr = np.array(img)

        return imageArr

    except Exception as e:
        print(f"ERROR downloading {key} from {UPLOAD_BUCKET_NAME} bucket")
        raise e
    
def resize_image(imgArr, scale):
    print("Printing shape of image array")
    print(imgArr.shape)
    width = int(imgArr.shape[1] * scale / 100)
    height = int(imgArr.shape[0] * scale / 100)
    dim = (width, height)
    resizedImage = cv2.resize(imgArr, dim, interpolation = cv2.INTER_AREA)
    print(resizedImage.shape)
    return resizedImage

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