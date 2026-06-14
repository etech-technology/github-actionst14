variable "aws_region" {
  description = "AWS region for the S3 bucket and provider."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "github_owner" {
  description = "GitHub username or organization that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name without the owner prefix."
  type        = string
}
