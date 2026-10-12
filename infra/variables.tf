variable "region" {
  type    = string
  default = "us-west-2"
}

variable "github_repo" {
  type        = string
  description = "允许扮演此角色的仓库，格式 owner/repo（信任范围的核心限制）"
  default     = "zhusiyu6257-byte/github-actions-oidc-lab"
}
