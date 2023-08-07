import boto3
import json


def lambda_handler(event, context):
    client = boto3.client("lambda")

    function_name = "weatherNotification"

    TELEGRAM_CHAT_ID = "-1001800796471"
    CITY_NAME = "Katowice"
    payload = {
        "telegram_chat_id": TELEGRAM_CHAT_ID,
        "city_name": CITY_NAME,
    }

    client.invoke(
        FunctionName=function_name,
        InvocationType="Event",
        Payload=json.dumps(payload),
    )
