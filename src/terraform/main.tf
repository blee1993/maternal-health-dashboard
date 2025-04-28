# Connect AWS credentials
provider "aws" {
    region = var.aws_region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

# Deploy S3 bucket for storing data
resource "aws_s3_bucket" "data_bucket" {
  bucket = var.data_bucket_name
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = var.lambda_execution_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# IAM Policy Attachment for Lambda
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = var.lambda_basic_execution_policy_name
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Deploy lambda function
resource "aws_lambda_function" "ingestion_lambda" {
  function_name = var.lambda_name

  s3_bucket = var.lambda_artifact_bucket
  s3_key    = var.lambda_key

  handler   = "index.handler"
  runtime   = "python3.12"  
  role      = aws_iam_role.lambda_execution_role.arn

  environment {
    variables = {
      DATA_BUCKET_NAME = aws_s3_bucket.data_bucket.bucket
    }
  }

  depends_on = [
    aws_iam_role.lambda_execution_role,
    aws_iam_policy_attachment.lambda_basic_execution
  ]

}