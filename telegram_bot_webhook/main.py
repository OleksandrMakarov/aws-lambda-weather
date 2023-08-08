import boto3
import json
import os

FUNCTION_NAME = os.environ.get("WEATHER_NOTIFICATION_LAMBDA")
TABLE_NAME = os.environ.get("TABLE_NAME")


def lambda_handler(event, context):
    print("event:", event)

    body = event.get("body")
    content = json.loads(body)
    message = content.get("message")
    chat = message.get("chat")
    telegram_chat_id = chat.get("id")
    raw_input = message.get("text")

    if not raw_input or not telegram_chat_id:
        return

    input = raw_input[:30]
    city_name = None if input == "/start" else input

    payload = {
        "telegram_chat_id": telegram_chat_id,
        "city_name": city_name,
    }

    client = boto3.client("lambda")
    client.invoke(
        FunctionName=FUNCTION_NAME,
        InvocationType="Event",
        Payload=json.dumps(payload),
    )

    # if input != "/start":
    #     dynamodb = boto3.resource('dynamodb')
    #     table = dynamodb.Table(TABLE_NAME)

    #     table.put_item(
    #         Item={
    #             'chat_id': str(telegram_chat_id),
    #             'city_name': str(city_name),
    #         },
    #         ConditionExpression='attribute_not_exists(chat_id)'
    #     )

    if input != "/start":
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table(TABLE_NAME)

        table.update_item(
            Key={
                'chat_id': str(telegram_chat_id)
            },
            UpdateExpression="SET city_name = :city_name",
            ExpressionAttributeValues={
                ':city_name': str(city_name)
            },
        )
