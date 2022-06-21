import json

import boto3
from datetime import datetime


def lambda_handler(event, context):
    client = boto3.resource('dynamodb')
    table = client.Table('people')
    today = datetime.today()
    body = json.loads(event['body'])
    birthday_str = body['dateOfBirth']
    valid = validate_date(birthday_str)
    if valid:
        birthday = datetime.strptime(birthday_str, '%Y-%m-%d')
        username = event['pathParameters']['username']
        if birthday < today:
            if username.isalpha():
                table.put_item(
                    Item=
                    {
                        'username': username,
                        'birthday': birthday_str
                    }
                )
                return {
                    'statusCode': '204',
                }
            else:
                return {
                    'statusCode': '400',
                    'body': 'Bad Input: username accepts only letters'
                }
        else:
            return {
                'statusCode': '400',
                'body': 'Bad Input: dateOfBirth is after today'
            }
    else:
        return {
            'statusCode': '400',
            'body': 'Bad Input: wrong date format'
        }


def validate_date(date_str):
    try:
        datetime.strptime(date_str, '%Y-%m-%d')
        return True
    except ValueError:
        return False
