output "data_bucket_name" {
  description = "Name of the S3 bucket for ingestion data"
  value       = aws_s3_bucket.data_bucket.bucket
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.ingestion_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.ingestion_lambda.arn
}