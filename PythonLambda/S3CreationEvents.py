import json, boto3, datetime

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Get the bucket name and key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    # Perform the specific action
    # For example, add tags with timestamp and project
    
    # Create a timestamp string
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    project = 'TestProject'

    # Add tags to object in S3
    tags = [
        {
            'Key': 'Project',
            'Value': project
        },
        {
            'Key': 'CretionDate',
            'Value': timestamp
        },
    ]
    response = add_tags_to_object(bucket_name, object_key, tags)
    
    # Sent a message about object by email
    message = f"A new object was created in S3 bucket: {bucket_name}: {object_key}  \
                link to object: s3://{bucket_name}/{object_key}"
    subject = "New object was created in S3 bucket"
    send_letter_by_email(subject, message)

    return {
        'statusCode': 200,
        'body': json.dumps('Created object {object_key} on S3 object')
    }
    

def add_tags_to_object(bucket_name, object_key, tags):
    response = s3.put_object_tagging(
        Bucket=bucket_name,
        Key=object_key,
        Tagging={
        'TagSet': tags
        }
    )
    #print tags to CloudWatch Logs 
    print(f"Added tags {tags} to object {object_key} in bucket {bucket_name}")
    return response

def send_letter_by_email(subject,message):
    # Get variable from function parameters
    Subject = subject
    Message = message
    
    # Sending email by sns
    print("Sending email with message...")
    
    #print message to CloudWatch Logs 
    print(Message)
   
    client = boto3.client('sns')
    client.publish(
            TargetArn='arn:aws:sns:us-east-1:883126580074:Notification-Topic',
            Subject=(Subject),
            Message=(Message)
        )

