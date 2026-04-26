

# --- SQS Queue (The Trigger) ---
resource "aws_sqs_queue" "notifications_queue" {
  name                      = "${var.project_name}-${var.environment}-notifications-queue"
  message_retention_seconds = 86400
  visibility_timeout_seconds = 30 # Should be >= Lambda timeout
}

# --- IAM Role for Lambda ---
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-notification-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" } # Fixed broken principal
    }]
  })
}

# --- IAM Policy (Least Privilege) ---
resource "aws_iam_role_policy" "lambda_permissions" {
  name = "${var.project_name}-${var.environment}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.notifications_queue.arn
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = aws_dynamodb_table.audit_logs.arn
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
  Effect   = "Allow"
  Action   = [
    "sns:Publish",          # For SMS or SNS Email
    "ses:SendEmail",        # For formal SES Email
    "ses:SendRawEmail"
  ]
  Resource = "*" # Or restrict to specific Topic/Identity ARNs
}
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "modules/lambda/lambda_code" # Put your index.js in this folder
  output_path = "modules/lambda/notification_code.zip"
}


# --- Lambda Function ---
resource "aws_lambda_function" "notification_worker" {
  function_name = "${var.project_name}-${var.environment}-notification-worker"
  role          = aws_iam_role.lambda_role.arn # Fixed mismatched reference
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  
  # Best practice: use a dummy file or data source if the zip isn't ready
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      DYNAMO_TABLE = aws_dynamodb_table.audit_logs.name
      NOTIFICATION_TOPIC = aws_sns_topic.user_updates.arn #
    }
  }
}
# Example SNS Topic for notifications
resource "aws_sns_topic" "user_updates" {
  name = "${var.project_name}-${var.environment}-notifications"
}

# --- SQS to Lambda Mapping ---
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.notifications_queue.arn
  function_name    = aws_lambda_function.notification_worker.arn
  batch_size       = 10 # Process up to 10 messages at once for efficiency
}

# --- DynamoDB Table ---
# --- DynamoDB Table ---
resource "aws_dynamodb_table" "audit_logs" {
  name         = "${var.project_name}-${var.environment}-audit-logs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TransactionID"
  range_key    = "Timestamp"

  attribute {
    name = "TransactionID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }
}