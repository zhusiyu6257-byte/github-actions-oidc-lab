variable "region" {
  type    = string
  default = "us-west-2"
}

variable "github_sub" {
  type        = string
  description = "信任策略精确匹配的 sub 声明（GitHub 新格式带 owner/repo 的数字 ID）。取真实值方法：跑一次 workflow 的 debug 步骤，读仓库里的 oidc-debug.txt"
  default     = "repo:zhusiyu6257-byte@240390313/github-actions-oidc-lab@1414912749:ref:refs/heads/main"
}
