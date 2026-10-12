terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region
}

# GitHub Actions 的 OIDC 身份提供者（Identity Provider）
# 一次性配置：告诉 AWS "GitHub 签发的 token 是可以信的"
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # GitHub 证书指纹（官方文档给的值）
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
