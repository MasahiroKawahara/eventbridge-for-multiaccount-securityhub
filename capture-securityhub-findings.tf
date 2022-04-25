resource aws_cloudwatch_event_bus custom {
  name = "custom-securityhub-bus"
}

resource aws_cloudwatch_event_rule to_custom {
  name           = "capture-securityhub-findings"
  event_bus_name = "default"

  event_pattern = <<-EOF
    {
      "source": ["aws.securityhub"],
      "detail-type": ["Security Hub Findings - Imported"],
      "detail": {
        "findings": {
          "ProductName": ["Security Hub"],
          "RecordState": ["ACTIVE"],
          "Severity": {
            "Label": ["CRITICAL", "HIGH"]
          },
          "Compliance": {
            "Status": [
              { "anything-but": "PASSED" }
            ]
          },
          "Workflow": {
            "Status": ["NEW"]
          }
        }
      }
    }
  EOF
}

resource aws_cloudwatch_event_target to_custom {
  event_bus_name = "default"
  rule           = aws_cloudwatch_event_rule.to_custom.name
  target_id      = "custom-securityhub-bus"
  role_arn       = aws_iam_role.to_custom.arn
  arn            = aws_cloudwatch_event_bus.custom.arn
}

# IAM Role for EventBridge
resource aws_iam_role to_custom {
  name = "capture-securityhub-findings-role"

  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "events.amazonaws.com"
          },
          "Effect": "Allow"
        }
      ]
    }
  EOF

  inline_policy {
    name   = "events-PutEvents"
    policy =  <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": "events:PutEvents",
            "Resource": "${aws_cloudwatch_event_bus.custom.arn}"
          }
        ]
      }
    EOF
  }
}
