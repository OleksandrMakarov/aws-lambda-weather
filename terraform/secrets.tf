resource "aws_secretsmanager_secret" "bot_secrets" {
  name                    = var.aws_secret_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bot_secrets_version" {
  secret_id = aws_secretsmanager_secret.bot_secrets.id
  secret_string = jsonencode({
    WEATHER_API_KEY = var.weather_api_key,
    TELEGRAM_TOKEN  = var.telegram_token
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
