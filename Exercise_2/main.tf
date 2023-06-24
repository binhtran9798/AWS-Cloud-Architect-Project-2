provider "aws" {
  region                  = "us-east-1"
  profile                 = "default"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 5
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "output.zip"
}

resource "aws_iam_role" "iam_exec_lambda" {
  name = "iam_exec_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy_logging" {
  name        = "lambda_policy_logging"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_lambda_logs" {
  role       = aws_iam_role.iam_exec_lambda.name
  policy_arn = aws_iam_policy.lambda_policy_logging.arn
}

resource "aws_lambda_function" "lambda_greeting_Function" {
  filename         = "output.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "${var.lambda_name}.lambda_handler"
  function_name    = var.lambda_name
  runtime          = "python3.8"
  role             = aws_iam_role.iam_exec_lambda.arn

  environment {
    variables = {
      greeting = "Hello World!"
    }
  }

  depends_on = [aws_cloudwatch_log_group.log_group, aws_iam_role_policy_attachment.policy_lambda_logs]
}
