resource "aws_lambda_function" "telegram_bot_webhook" {
  filename         = var.telegram_bot_webhook_zip_path
  source_code_hash = filebase64sha256(var.telegram_bot_webhook_zip_path)
  function_name    = "TelegramBotWebhook"
  role             = var.iam_role_arn
  handler          = "main.lambda_handler"
  runtime          = "python3.10"

  environment {
    variables = {
      WEATHER_NOTIFICATION_LAMBDA = var.weather_notification_lambda_name
      TABLE_NAME                  = var.table_name
    }
  }
}

resource "aws_lambda_function_url" "lambda_function_url" {
  function_name      = aws_lambda_function.telegram_bot_webhook.arn
  authorization_type = "NONE"
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
  role       = var.iam_role_name
  policy_arn = aws_iam_policy.telegram_bot_webhook_logging.arn
}
