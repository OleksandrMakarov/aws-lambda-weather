module "weather_notification" {
  source = "./weather_module"
  weather_notification_zip_path = var.weather_notification_zip_path
  iam_role_arn = aws_iam_role.iam_lambda.arn
  iam_role_name = aws_iam_role.iam_lambda.name
  aws_region = var.aws_region
  aws_account_id = var.aws_account_id
  aws_secret_name = var.aws_secret_name
  table_name = aws_dynamodb_table.telegram_bot_users.name

}

