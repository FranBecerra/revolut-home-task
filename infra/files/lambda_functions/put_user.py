import json

import boto3
from datetime import datetime


def lambda_handler(event, context):
    client = boto3.resource('dynamodb')
    table = client.Table('people')
    today = datetime.today()
    body = json.loads(event['body'])
    birthday_str = body['dateOfBirth']
    birthday = datetime.strptime(birthday_str, '%Y-%m-%d')
    if birthday < today:
        username = event['pathParameters']['username']
        response = table.put_item(
            Item=
            {
                'username': username,
                'birthday': birthday_str
            }
        )
        return {
            'statusCode': response['ResponseMetadata']['HTTPStatusCode'],
            'body': 'User ' + username + ' added'
        }
    else:
        return {
            'statusCode': '400',
            'body': 'Bad Input: dateOfBirth is after today'
        }