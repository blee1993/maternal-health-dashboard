
variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"  #YOUR_REGION
}

variable "data_bucket_name" {
    type = string
    description = "Name of the S3 bucket to store ingestion data"
    default = "blee-maternal-data" #YOUR_DATA_BUCKET_NAME
}

variable "lambda_artifact_bucket" {
    type = string
    description = "Name of the existing S3 bucket where the Lambda zip artifact is stored."
    default = "blee-lambda-artifact" #YOUR_LAMBDA_ARTIFACT_BUCKET_NAME
}

variable "lambda_key" {
    type = string
    description = "S3 key path to Lambda zip artifact"
    default = "resources/fetch-data-lambda/fetch-data-lambda.zip" #YOUR_LAMBDA_ZIP_PATH
}

variable "lambda_name" {
    default = "fetch-data-lambda"
}

variable "lambda_execution_iam_role_name" {
    default = "FetchData-LambdaExecutionRole"
}

variable "lambda_basic_execution_policy_name" {
    default = "LambdaExecutionBasicPolicy"
}