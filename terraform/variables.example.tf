variable "weather_notification_zip_path" {
  description = "Path to Python zip-file for AWS Lambda"
  default     = "./../weather_notification.zip"
}


variable "telegram_bot_webhook_zip_path" {
  description = "Path to Python zip-file for AWS Lambda"
  default     = "./../telegram_bot_webhook.zip"
}


variable "arn_secrets_manager" {
  description = "ARN of AWS Secrets Manager"
  default     = ""
}


variable "aws_region" {
  description = "AWS region"
  default     = ""
}

variable "aws_secret_name" {
  description = "AWS secret name"
  default     = ""
}