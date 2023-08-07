import boto3
import json
import os


def lambda_handler(event, context):
    print("event:", event)

    content = json.loads(event['body'])
    telegram_chat_id = content["message"]["chat"]["id"]
    input = content["message"]["text"]
    city_name = None if input == "/start" else input

    payload = {
        "telegram_chat_id": telegram_chat_id,
        "city_name": city_name,
    }

    client = boto3.client("lambda")
    function_name = os.environ.get("WEATHER_NOTIFICATION_LAMBDA")
    client.invoke(
        FunctionName=function_name,
        InvocationType="Event",
        Payload=json.dumps(payload),
    )
