variable "prefix" {
  description = "The prefix used for all resources in this example"
  default     = "toa"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "westeurope"
}

variable "subscription_id" {
  description = "Azure Subscription ID to be used for billing"
}

variable "remote_state_rg" {
  description = "Resoure group where our remote state storage account sits"
}

variable "remote_state_storage" {
  description = "Storage account for our remote state"
}

variable "remote_state_container_name" {
  description = "Storage account container name for our remote state"
}

variable "remote_state_key" {
  description = "Key name of our remote state"
}
