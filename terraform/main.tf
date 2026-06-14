data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "GitHubActionsOIDC"
  }
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    sid     = "AllowGitHubActionsOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/main",
        "repo:${var.github_owner}/${var.github_repository}:environment:production"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "GitHubActionsS3Deploy-${var.github_repository}"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = {
    Name = "GitHubActionsS3Deploy-${var.github_repository}"
  }
}

data "aws_iam_policy_document" "s3_deployment" {
  statement {
    sid    = "ListTargetBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.website.arn
    ]
  }

  statement {
    sid    = "ManageTargetBucketObjects"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.website.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_deployment" {
  name   = "DeployTo-${var.bucket_name}"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.s3_deployment.json
}
