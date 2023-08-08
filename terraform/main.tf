provider "aws" {
  region = var.aws_region
}





resource "aws_iam_role" "iam_lambda" {
  name = "iam_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_access" {
  name        = "WeatherBotSecretsAccessPolicy"
  description = "Policy to allow lambda to access weatherBotSecrets in Secrets Manager."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = aws_secretsmanager_secret.bot_secrets.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_lambda_attach" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.secrets_access.arn
}
















resource "aws_iam_policy" "invoke_weather_notification_policy" {
  name        = "InvokeWeatherNotificationPolicy"
  description = "Allows invoking weather notification lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = module.weather_notification.weather_notification_lambda_arn
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "invoke_weather_notification_attach" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.invoke_weather_notification_policy.arn
}




resource "aws_dynamodb_table" "telegram_bot_users" {
  name           = "telegramBotUsers"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "chat_id"
  attribute {
    name = "chat_id"
    type = "S"
  }
}



resource "aws_iam_role_policy" "telegram_bot_users_policy" {
  name   = "TelegramBotUsersPolicy"
  role   = aws_iam_role.iam_lambda.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
        ],
        Resource = aws_dynamodb_table.telegram_bot_users.arn
        Effect   = "Allow"
      }
    ]
  })
}


resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "DailyWeatherNotification"
  description         = "Triggers the weather notification lambda daily"
  schedule_expression = "cron(0 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  arn       = module.weather_notification.weather_notification_lambda_arn
  input     = "{\"schedule\":\"True\"}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.weather_notification.weather_notification_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}

resource "aws_secretsmanager_secret" "bot_secrets" {
  name = var.aws_secret_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bot_secrets_version" {
  secret_id     = aws_secretsmanager_secret.bot_secrets.id
  secret_string = jsonencode({
    WEATHER_API_KEY = var.weather_api_key,
    TELEGRAM_TOKEN  = var.telegram_token
  })
}