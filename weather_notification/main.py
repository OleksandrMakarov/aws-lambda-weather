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
    print("Hello World!")
    secrets = get_secrets()

    WEATHER_API_KEY = secrets["WEATHER_API_KEY"]
    TELEGRAM_TOKEN = secrets["TELEGRAM_TOKEN"]
    TELEGRAM_CHAT_ID = "-1001800796471"
    YOUR_CITY = "Katowice"
    response = requests.get(
        f"https://api.openweathermap.org/data/2.5/weather?q={YOUR_CITY}&appid={WEATHER_API_KEY}"
    )
    weather_data = response.json()
    message = f"Weather in {YOUR_CITY}: {weather_data['weather'][0]['description']}"
    requests.get(
        f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage?chat_id={TELEGRAM_CHAT_ID}&text={message}"
    )
    print("weather_data:", weather_data)
