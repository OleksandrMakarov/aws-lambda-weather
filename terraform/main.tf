provider "aws" {
  region = var.aws_region
}

resource "aws_lambda_function" "weather_notification" {
  filename         = var.weather_notification_zip_path
  source_code_hash = filebase64sha256(var.weather_notification_zip_path)
  function_name    = "weatherNotification"
  role             = aws_iam_role.iam_lambda.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.10"

  environment {
    variables = {
      REGION_NAME     = var.aws_region
      AWS_SECRET_NAME = var.aws_secret_name
    }
  }
}

resource "aws_lambda_function" "telegram_bot_webhook" {
  filename         = var.telegram_bot_webhook_zip_path
  source_code_hash = filebase64sha256(var.telegram_bot_webhook_zip_path)
  function_name    = "TelegramBotWebhook"
  role             = aws_iam_role.iam_lambda.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.10"
  environment {
    variables = {
      WEATHER_NOTIFICATION_LAMBDA = aws_lambda_function.weather_notification.function_name
      TABLE_NAME = aws_dynamodb_table.telegram_bot_users.name
    }
  }
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
        Resource = var.arn_secrets_manager
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_lambda_attach" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "aws_lambda_function_url" "lambda_function_url" {
  function_name      = aws_lambda_function.telegram_bot_webhook.arn
  authorization_type = "NONE"
}


resource "aws_cloudwatch_log_group" "weather_notification_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.weather_notification.function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "weather_notification_logging" {
  name        = "WeatherNotificationLoggingPolicy"
  description = "Allows a weatherNotification to write logs to CloudWatch."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${aws_lambda_function.weather_notification.function_name}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "weather_notification_logs_attach" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.weather_notification_logging.arn
}

resource "aws_cloudwatch_log_group" "telegram_bot_webhook_log" {
  name              = "/aws/lambda/${aws_lambda_function.telegram_bot_webhook.function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "telegram_bot_webhook_logging" {
  name        = "TelegramBotWebhookLoggingPolicy"
  description = "Allows a TelegramBotWebhook to write logs to CloudWatch."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${aws_lambda_function.telegram_bot_webhook.function_name}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "telegram_bot_webhook_logs_attach" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.telegram_bot_webhook_logging.arn
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
        Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${aws_lambda_function.weather_notification.function_name}",
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
          "dynamodb:PutItem"
        ],
        Resource = aws_dynamodb_table.telegram_bot_users.arn
        Effect   = "Allow"
      }
    ]
  })
}
























# resource "aws_cloudwatch_event_rule" "daily_trigger" {
#   name                = "DailyWeatherNotification"
#   description         = "Triggers the weather notification lambda daily"
#   schedule_expression = "rate(1 day)"
# }

# resource "aws_cloudwatch_event_target" "trigger_lambda" {
#   rule      = aws_cloudwatch_event_rule.daily_trigger.name
#   arn       = aws_lambda_function.weather_notification.arn
# }

# resource "aws_lambda_permission" "allow_cloudwatch" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.weather_notification.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
# }
