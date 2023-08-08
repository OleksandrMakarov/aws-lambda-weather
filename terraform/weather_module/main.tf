resource "aws_lambda_function" "weather_notification" {
  filename         = var.weather_notification_zip_path
  source_code_hash = filebase64sha256(var.weather_notification_zip_path)
  function_name    = "weatherNotification"
  role             = var.iam_role_arn
  handler          = "main.lambda_handler"
  runtime          = "python3.10"

  environment {
    variables = {
      REGION_NAME     = var.aws_region
      AWS_SECRET_NAME = var.aws_secret_name
      TABLE_NAME = var.table_name
    }
  }
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
  role       = var.iam_role_name
  policy_arn = aws_iam_policy.weather_notification_logging.arn
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
        Resource = aws_lambda_function.weather_notification.arn
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "invoke_weather_notification_attach" {
  role       = var.iam_role_name
  policy_arn = aws_iam_policy.invoke_weather_notification_policy.arn
}
