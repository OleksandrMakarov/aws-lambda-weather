# aws-lambda-weather

## Create new Bot on Telegram

## Create account on OpenWeather and get API key

## Login to AWS and create secrets for WEATHER_API_KEY, TELEGRAM_TOKEN

## Rename variables.example.tf to variables.tf and fill out with your data

## Install requirements

```powershell
cd ~\aws-lambda-weather\weather_notification

pip install -r requirements.txt -t ./

Compress-Archive -Force -Path * -DestinationPath .\..\weather_notification.zip

cd ~\aws-lambda-weather\telegram_bot_webhook
pip install -r requirements.txt -t ./
Compress-Archive -Force -Path * -DestinationPath .\..\telegram_bot_webhook.zip


cd ~\aws-lambda-weather\terraform

terraform init
terraform plan
terraform apply
terraform destroy

