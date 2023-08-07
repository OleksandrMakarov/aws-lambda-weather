provider "aws" {
  region = var.aws_region
}

resource "aws_lambda_function" "weather_notification" {
  filename         = var.weather_notification_zip_path
  source_code_hash = filebase64sha256(var.weather_notification_zip_path)
  function_name    = "weatherNotification"
  role             = aws_iam_role.lambda_exec.arn
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
  role             = aws_iam_role.lambda_exec.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.10"

}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

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
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.secrets_access.arn
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
