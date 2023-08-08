# aws-lambda-weather

This repo contains terraform and python files and structures. It allows to create AWS infrastructure for Telegram weather bot.

Bot will send weather notification for provided city hourly. If it needs to change city, please provide new city name to Bot

## Prerequisites

- aws account
- aws cli
- terraform
- pip package manager

## AWS resources will be created

- Lambda (bot webhook and weather notification service)
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

Please run next commands to create libs folder for both lambda functions and create zip archives

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

## 6. Create AWS infrastructure using Terraform

Please run next commands to create AWS infrastructure and get links to set up and delete webhook.

It needs to confirm operation during **terraform apply**, or add flag **-auto-approve**

```powershell
cd ~\aws-lambda-weather\terraform
terraform init
terraform plan
terraform apply
```

As a result next output values will be received on terminal.

Use ***deleteWebhook_url*** to delete previous webhook or reassure that previous webhook is deleted.

Use ***setWebhook_url*** to set up new web hook on Telegram API

It needs to use this links before first infrastructure use or after destroying Terraform infrastructure and reapply it.

- deleteWebhook_url =

```html
https://api.telegram.org/bot<TELEGRAM_TOKEN>/deleteWebhook"
```

- setWebhook_url =

```html
https://api.telegram.org/bot<TELEGRAM_TOKEN>/setWebhook?url=<FUNCTION_URL>
```

## 7. Destroy infrastructure

To destroy infrastructure use next commands.

It needs to confirm operation during **terraform destroy**, or add flag **-auto-approve**

```powershell
cd ~\aws-lambda-weather\terraform
terraform destroy
```
