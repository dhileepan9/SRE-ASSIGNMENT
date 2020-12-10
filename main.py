from boto import BUCKET_NAME_RE
import boto3
import datetime
from datetime import timezone
'''
AWS CREDENTIALS ARE ALREADY CONFIGURED USING AWS CLI.
'''

s3_resource = boto3.resource('s3')

#set date to 30 days back to check if s3 object is older than 30 days
olddate= datetime.datetime.now(timezone.utc) - datetime.timedelta(days=30)
s3 = boto3.client('s3')

# List to store the bucket names which ends with '.test'
bucketList = [] 

# List to '.xml'  type objects which should be marked delete or expired
expiredObjects = []

#Get all s3 bucket from aws account 
for bucket in s3_resource.buckets.all():
    # filter the bucket name which ends with '.test'
    if bucket.name.endswith(".test"):
        bucketList.append(bucket.name)
        objects = s3.list_objects(Bucket=bucket.name)
        for s3objects in objects["Contents"]:
            # filter objects with are 30 days old
            if s3objects["LastModified"] < olddate:
                # filter objects with ".xml" extension
                if s3objects["Key"].endswith(".xml"):
                    expiredObjects.append((s3objects["Key"]))
                    s3_resource.Object(bucket.name, s3objects["Key"]).delete()
    

if len(expiredObjects) == 0:
    print("No objects are expired")
else:
    print("Objects Expired : ",expiredObjects)
 
