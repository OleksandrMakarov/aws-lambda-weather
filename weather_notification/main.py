import os
import requests
import boto3


secret_name = os.environ.get("AWS_SECRET_NAME")
region_name = os.environ.get("REGION_NAME")
table_name = os.environ.get("TABLE_NAME")

client = boto3.client("secretsmanager", region_name=region_name)
response = client.get_secret_value(SecretId=secret_name)
secrets = eval(response["SecretString"])

WEATHER_API_KEY = secrets.get("WEATHER_API_KEY")
TELEGRAM_TOKEN = secrets.get("TELEGRAM_TOKEN")


def get_users_db():
    dynamodb = boto3.resource("dynamodb", region_name=region_name)
    table = dynamodb.Table(table_name)
    response = table.scan()
    items = response["Items"]
    return items


def get_weather_message(city_name):
    response = requests.get(
        f"https://api.openweathermap.org/data/2.5/weather?q={city_name}&appid={WEATHER_API_KEY}"
    )
    weather_data = response.json()
    message = f"Weather in {city_name}: {weather_data['weather'][0]['description']}"
    return message


def send_telegram_message(message, chat_id):
    requests.get(
                f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage?chat_id={chat_id}&text={message}"
            )


def lambda_handler(event, context):
    print("event:", event)
    print("is event none:", event is None)
    schedule_details = event.get("detail")
    if schedule_details.get("schedule"):
        users = get_users_db()
        print("users:", users)
        for chat_id, city_name in users:
            message = get_weather_message(city_name)
            send_telegram_message(message, chat_id)
        return

    telegram_chat_id = event.get("telegram_chat_id")
    city_name = event.get("city_name")

    if not telegram_chat_id:
        print("not chat_id")
        return

    if city_name is None:
        message = "Please provide your city name"
    else:
        message = get_weather_message(city_name)

    send_telegram_message(message, telegram_chat_id)
