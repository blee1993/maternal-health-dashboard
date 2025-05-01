# Connect AWS credentials
provider "aws" {
    region = var.aws_region
}

# Deploy S3 bucket for storing data
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
resource "aws_s3_bucket" "data_bucket" {
  bucket = "${var.data_bucket_name}-${random_id.bucket_suffix.hex}"
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

# Random Password / Suffix

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!$%&*()-_=+[]{}<>:?"
}

resource "random_string" "unique_suffix" {
  length  = 6
  special = false
}

# Resources

resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier = "tf-redshift-cluster"
  database_name      = "healthdb"
  master_username    = "admin"
  master_password    = random_password.password.result
  node_type          = "dc2.large"
  cluster_type       = "single-node"

  skip_final_snapshot = true
}

resource "aws_secretsmanager_secret" "redshift_connection" {
  description = "Redshift connect details"
  name        = "redshift_secret_${random_string.unique_suffix.result}"
}

resource "aws_secretsmanager_secret_version" "redshift_connection" {
  secret_id = aws_secretsmanager_secret.redshift_connection.id
  secret_string = jsonencode({
    username            = aws_redshift_cluster.redshift_cluster.master_username
    password            = aws_redshift_cluster.redshift_cluster.master_password
    engine              = "redshift"
    host                = aws_redshift_cluster.redshift_cluster.endpoint
    port                = "5439"
    dbClusterIdentifier = aws_redshift_cluster.redshift_cluster.cluster_identifier
  })
}