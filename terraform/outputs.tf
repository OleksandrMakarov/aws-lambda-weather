output "setWebhook_url" {
  description = "URL to set Webhook"
  value = "https://api.telegram.org/bot${var.telegram_token}/setWebhook?url=${aws_lambda_function_url.lambda_function_url.function_url}"
}

output "deleteWebhook_url" {
  description = "URL to delete Webhook"
  value = "https://api.telegram.org/bot${var.telegram_token}/deleteWebhook"
}