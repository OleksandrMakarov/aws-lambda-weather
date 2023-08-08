module "telegram_bot" {
  source = "./telegram_module"
  telegram_bot_webhook_zip_path = var.telegram_bot_webhook_zip_path
  iam_role_arn = aws_iam_role.iam_lambda.arn
  iam_role_name = aws_iam_role.iam_lambda.name
  weather_notification_lambda_name = module.weather_notification.weather_notification_lambda_name
  table_name = aws_dynamodb_table.telegram_bot_users.name
  aws_region = var.aws_region
  aws_account_id = var.aws_account_id
}