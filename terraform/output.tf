output "setWebhook_url" {
  description = "URL to set Webhook"
  value = "https://api.telegram.org/bot${var.telegram_token}/setWebhook?url=${module.telegram_bot.webhook_url}"
}

output "deleteWebhook_url" {
  description = "URL to delete Webhook"
  value = "https://api.telegram.org/bot${var.telegram_token}/deleteWebhook"
}