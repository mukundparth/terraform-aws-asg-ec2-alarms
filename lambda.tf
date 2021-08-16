#IAM Role for Lambda function
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}


# Attach policy for logs snd additionls
data "aws_iam_policy_document" "logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "logs" {
  name   = "${var.name}-logs"
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_policy_attachment" "logs" {
  name       = "${var.name}-logs"
  roles      = [aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.logs.arn
}


data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.alarm_templates.id}/*",
    ]
  }
}

resource "aws_iam_policy" "additional" {
  name   = var.name
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_policy_attachment" "additional" {
  name       = var.name
  roles      = [aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.additional.arn
}

#Lambda function
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "${path.module}/package"
  output_path = "${path.module}/lambda.zip"
}

# AWS Lambda function
resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda.output_path
  function_name    = var.name
  role             = aws_iam_role.lambda.arn
  handler          = "lambda.lambda_handler"
  runtime          = "python3.7"
  timeout          = 30
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      ALARM_TEMPLATES_BUCKET = aws_s3_bucket.alarm_templates.id
    }
  }
}
