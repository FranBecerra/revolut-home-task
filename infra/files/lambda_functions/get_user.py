import boto3
from datetime import datetime


def lambda_handler(event, context):
    client = boto3.resource('dynamodb')
    table = client.Table('people')
    response = table.get_item(
        Key={
            'username': event['path']
        }
    )
    ## Siempre hay item
    if 'Item' in response:
        birthday_str = response['Item']['birthday']
        birthday = datetime.strptime(birthday_str, '%Y-%m-%d')
        today = datetime.today()
        if (birthday.month == today.month) and (birthday.day == today.day):
            return {
                "statusCode": '200',
                "body": "{ \"message\": \"Hello\"" + response['Item']['username'] + "\"! Happy birthday!\" }"
            }
        else:
            diff = str(calculate_diff(birthday, today))
            return {
                "statusCode": '200',
                "body": "{ \"message\": \"Hello\"" + response['Item']['username'] + "\"! Your Birthday is in \"" +
                        diff + "\" days!\"}"
            }
    else:
        return {
            'statusCode': '404',
            'body': 'Not found'
        }


def calculate_diff(birthday, today):
    delta1 = datetime(today.year, birthday.month, birthday.day)
    delta2 = datetime(today.year + 1, birthday.month, birthday.day)
    return ((delta1 if delta1 > today else delta2) - today).days
