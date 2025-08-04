# File: variables.tf
variable "resource_group_name" {
  default = "billing-archive-rg"
}

variable "location" {
  default = "East US"
}

variable "storage_account_name" {
  default = "billingarchivestorage"
}

variable "function_app_name" {
  default = "billingarchivefn"
}

variable "app_service_plan_name" {
  default = "billing-archive-plan"
}

variable "cosmos_account_name" {
  default = "billing-cosmos-account"
}
