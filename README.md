# aws-lambda-weather

This repo contains terraform and python files and structures. It allows to create AWS infrastructure for Telegram weather bot.

Bot will send weather notification for provided city hourly. If it needs to change city, please provide new city name to Bot

## Prerequisites

- aws account
- aws cli
- terraform
- pip package manager

## Next AWS resources will be created

- Lambda (bot webhook and weather notification)
- DynamoDB (store chat id and city name for every user)
- CloudWatch (logs storage)
- EventBridge (rules for cron event)
- Secrets Manager (keep API keys)

## There are several steps to prepare and set up infrastructure

## 1. Create API token for Telegram bot

At first it needs to create API token for Telegram bot using BotFather.
There is a comprehensive guide how to do this:
[How to set up your Telegram bot using BotFather](https://blog.devgenius.io/how-to-set-up-your-telegram-bot-using-botfather-fd1896d68c02).

## 2. Create API key for OpenWeather

There is a comprehensive guide how to do this:
[OpenWeather FAQ](https://openweathermap.org/faq#onecall).

Just need to sign up and get API key on account page

## 3. Clone git repo

Folowing instructions assumed that PowerShell is used as main command shell

```powershell
cd ~
git clone git@github.com:OleksandrMakarov/aws-lambda-weather.git
cd ~\aws-lambda-weather\
```

## 4. Fill out variables file with necessary data

Rename variables.example to variables.tf and fill out with next data:

- aws_account_id (aws account id)
- aws_region (aws region where infrastructure will be created)
- aws_secret_name (any secret name)
- weather_api_key (API key from step 2)
- telegram_token (API token from step 1)

```powershell
cd ~\aws-lambda-weather\
Copy-Item "terraform\variables.example" -Destination "terraform\variables.tf"
code "terraform\variables.tf"
```

## 5. Install requirements for lambda function

Please prowide next commands to create libs folder for both lambda functions and create zip archives

- for weather notification function

```powershell
cd ~\aws-lambda-weather\weather_notification
New-Item -Path . -Name "libs" -ItemType Directory
pip install -r requirements.txt -t ./libs/
Compress-Archive -Force -Path * -DestinationPath .\..\weather_notification.zip
```

- for telegram bot webhook

```powershell
cd ~\aws-lambda-weather\telegram_bot_webhook
New-Item -Path . -Name "libs" -ItemType Directory
pip install -r requirements.txt -t ./libs/
Compress-Archive -Force -Path * -DestinationPath .\..\telegram_bot_webhook.zip
```

## Create AWS infrastructure using Terraform


cd ~\aws-lambda-weather\terraform

terraform init
terraform plan
terraform apply
terraform destroy
```

As a result of Terraform execution copy function_url from output

- Set your webhook url

```html
https://api.telegram.org/bot<TELEGRAM_TOKEN>/setWebhook?url=<FUNCTION_URL>
```

```html
https://api.telegram.org/bot<TELEGRAM_TOKEN>/deleteWebhook
```
