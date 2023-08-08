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
  name = "TelegramBotUsersPolicy"
  role = aws_iam_role.iam_lambda.id
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
