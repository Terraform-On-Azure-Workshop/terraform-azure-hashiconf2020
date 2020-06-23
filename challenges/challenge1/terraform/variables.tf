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
