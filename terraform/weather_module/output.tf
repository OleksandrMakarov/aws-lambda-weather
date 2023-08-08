output "weather_notification_lambda_name" {
  value = aws_lambda_function.weather_notification.function_name
}

output "weather_notification_lambda_arn" {
  value = aws_lambda_function.weather_notification.arn
}