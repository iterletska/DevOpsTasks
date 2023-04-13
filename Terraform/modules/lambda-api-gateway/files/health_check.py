import json
import requests
import boto3

urls = ['https://google.com/','https://dou.ua/','https://someunhealthysite/']
_return = []

failchklist=[]

def healthcheck(urls,urls_from_api=[]):
    urls = urls
    urls_from_api = urls_from_api
    urls.extend(urls_from_api)
    for url in urls:
        try: 
            resp = requests.get(url, timeout=5)
            scode=resp.status_code
            print(scode)
            if  scode <= 399:
                print(url+' is healthy')
                if url in failchklist:
                    failchklist.remove(url)
                _return.append({
                        'url' : url,
                        'statusCode': scode,
                        'body': json.dumps("Healthy")
                })
            else:
                raise requests.exceptions.ConnectionError
        except (requests.exceptions.ConnectionError, requests.exceptions.Timeout):
            print(url+' is unhealthy')
            failchklist.append(url)
            if failchklist.count(url)>=3:
                # Sent a message about object by email
                message = url +' is Unhealthy!'
                subject = url +' is Unhealthy!'
                send_letter_by_email(subject, message)
                failchklist.pop(0)
            _return.append({
                    'url' : url,
                    'statusCode': scode,
                    'body': json.dumps("Unhealthy")
            })   


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


def lambda_handler(event, context):
    urls_from_api=[]
    request_body = event['body']
    urls_from_api = [request_body]
    healthcheck(urls,urls_from_api)
    return {   
        'body': json.dumps(_return)
    }