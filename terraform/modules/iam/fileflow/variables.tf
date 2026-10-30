variable "project_name" { type = string }
variable "deployment_environment" { type = string }
variable "eks_oidc_issuer" { type = string }
variable "oidc_thumbprint" { type = string }
variable "kubernetes_namespace" { type = string }
variable "api_service_account" { type = string }
variable "worker_service_account" { type = string }
variable "s3_bucket_arn" { type = string }
variable "files_table_arn" { type = string }
variable "events_table_arn" { type = string }
variable "processing_queue_arn" { type = string }

variable "resource_tags" {
  type    = map(string)
  default = {}
}
