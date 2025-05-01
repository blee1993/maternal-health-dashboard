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

output "redshift_cluster_identifier" {
  description = "Identifier of the Redshift cluster"
  value       = aws_redshift_cluster.redshift_cluster.cluster_identifier
}

output "redshift_cluster_endpoint" {
  description = "Endpoint address of the Redshift cluster"
  value       = aws_redshift_cluster.redshift_cluster.endpoint
}

output "redshift_database_name" {
  description = "Database name of the Redshift cluster"
  value       = aws_redshift_cluster.redshift_cluster.database_name
}

output "redshift_secret_arn" {
  description = "ARN of the Secrets Manager secret storing Redshift connection info"
  value       = aws_secretsmanager_secret.redshift_connection.arn
}