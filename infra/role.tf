# 信任策略（Trust Policy）：谁可以扮演这个角色
# 关键在两个 condition——这是 OIDC 安全性的核心：
#   aud = audience，必须是 sts.amazonaws.com（防止 token 被别的服务拿去用）
#   sub = subject，必须是"这个仓库的 main 分支"（防止其他仓库/人的 workflow 冒用）
data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-oidc-lab"
  description        = "Assumable by GitHub Actions via OIDC, least-privilege for VPC read-only lab"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
}

# 权限策略：最小权限原则
# 原博客直接给了 AdministratorAccess——那是不安全的示范
# 这里只放开"读 VPC 信息"需要的 4 个 Describe + 1 个身份查询
resource "aws_iam_role_policy" "vpc_readonly" {
  name = "vpc-readonly-describe"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInstances",
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "sts:GetCallerIdentity"
        Resource = "*"
      }
    ]
  })
}

output "role_arn" {
  description = "给 GitHub Actions workflow 用的角色 ARN"
  value       = aws_iam_role.github_actions.arn
}
