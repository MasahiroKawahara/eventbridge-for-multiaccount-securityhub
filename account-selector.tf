# ################
# Selector for AAA
# ################
resource aws_sns_topic aaa {
  name = "aaa-security-topic"
}


resource aws_sns_topic_policy aaa {
  arn = aws_sns_topic.aaa.arn
  policy =  <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "events.amazonaws.com"
          },
          "Action": "sns:Publish",
          "Resource": "*"
        }
      ]
    }
  EOF
}

resource aws_sns_topic_subscription aaa {
  topic_arn = aws_sns_topic.aaa.arn
  protocol  = "email"
  endpoint  = "example+aaa@example.com"
}

resource aws_cloudwatch_event_rule aaa {
  name           = "account-selector-aaa"
  event_bus_name = aws_cloudwatch_event_bus.custom.name

  event_pattern = <<-EOF
    {
      "detail": {
        "findings": {
          "AwsAccountId": ["123456789012"]
        }
      }
    }
  EOF
}

resource aws_cloudwatch_event_target aaa {
  event_bus_name = aws_cloudwatch_event_bus.custom.name
  rule           = aws_cloudwatch_event_rule.aaa.name
  target_id      = "sns-topic"
  arn            = aws_sns_topic.aaa.arn
}
