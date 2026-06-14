output "aws_account_id" {
  description = "AWS account where the resources were created."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region used by the workflow."
  value       = var.aws_region
}

output "s3_bucket_name" {
  description = "S3 bucket receiving the website files."
  value       = aws_s3_bucket.website.id
}

output "github_actions_role_arn" {
  description = "IAM role ARN to store as the AWS_ROLE_ARN GitHub variable."
  value       = aws_iam_role.github_actions.arn
}
