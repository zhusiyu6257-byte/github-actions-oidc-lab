# github-actions-oidc-lab

GitHub Actions 通过 OIDC（OpenID Connect）免密钥访问 AWS 的最小可用示例。

## 为什么用 OIDC 而不是 Access Key

传统做法是把 AWS Access Key 存进 GitHub Secrets——密钥长期有效、一旦泄露即失守。
OIDC 的做法：workflow 运行时向 GitHub 要一个**短时 JWT token**（默认 1 小时过期），
拿它去 AWS STS 换**临时凭证**。仓库里不存任何密钥，凭证用完即焚（零常驻权限）。

## 架构

```
GitHub Actions workflow
        │ 1. 向 GitHub OIDC 提供者请求 JWT（sub = 仓库+分支）
        ▼
AWS IAM OIDC Provider（信任 GitHub 签发的 token）
        │ 2. sts:AssumeRoleWithWebIdentity 校验 aud/sub
        ▼
IAM Role github-actions-oidc-lab（信任策略限定仓库，权限策略只读 EC2/VPC）
        │ 3. 返回临时凭证（15 分钟 ~ 12 小时）
        ▼
workflow 用临时凭证执行 aws ec2 describe-* 列出 Terraform 建的 VPC
```

## 信任范围（安全核心）

- `aud` 必须是 `sts.amazonaws.com`
- `sub` 必须是 `repo:zhusiyu6257-byte/github-actions-oidc-lab:ref:refs/heads/main`
  —— 只有这个仓库的 main 分支能扮演该角色，其他仓库、其他分支一律拒绝

## 文件

- `infra/` —— Terraform：OIDC 提供者 + IAM 角色（最小权限：5 个只读 API）
- `.github/workflows/list-vpc.yml` —— 演示 workflow

## 复现步骤

1. `cd infra && terraform init && terraform apply`
2. 把 `role_arn` 输出填进 workflow（或放 repo secrets / variables）
3. push 到 main，workflow 自动触发
