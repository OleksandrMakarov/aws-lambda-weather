import os
import requests
import boto3


def get_secrets():
    secret_name = os.environ.get("AWS_SECRET_NAME")
    region_name = os.environ.get("REGION_NAME")
    client = boto3.client("secretsmanager", region_name=region_name)
    response = client.get_secret_value(SecretId=secret_name)
    return eval(response["SecretString"])


def lambda_handler(event, context):
    print("event:", event)
    TELEGRAM_CHAT_ID = event["telegram_chat_id"]
    if not TELEGRAM_CHAT_ID:
        return

    secrets = get_secrets()
    WEATHER_API_KEY = secrets["WEATHER_API_KEY"]
    TELEGRAM_TOKEN = secrets["TELEGRAM_TOKEN"]
    CITY_NAME = event["city_name"]

    if CITY_NAME is None:
        message = "Please provide your city name"
    else:
        response = requests.get(
            f"https://api.openweathermap.org/data/2.5/weather?q={CITY_NAME}&appid={WEATHER_API_KEY}"
        )
        weather_data = response.json()
        message = f"Weather in {CITY_NAME}: {weather_data['weather'][0]['description']}"

    requests.get(
        f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage?chat_id={TELEGRAM_CHAT_ID}&text={message}"
    )
