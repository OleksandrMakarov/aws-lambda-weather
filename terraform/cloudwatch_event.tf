resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "DailyWeatherNotification"
  description         = "Triggers the weather notification lambda daily"
  schedule_expression = "cron(0 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule  = aws_cloudwatch_event_rule.daily_trigger.name
  arn   = module.weather_notification.weather_notification_lambda_arn
  input = "{\"schedule\":\"True\"}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.weather_notification.weather_notification_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
