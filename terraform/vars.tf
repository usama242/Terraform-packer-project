variable "resource_group" {
  description = "Name of the resource group where the packer image is"
  default     = "Azuredevops"
  type        = string
}

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "udacity"
  type        = string
}

variable "location" {
  description = "The Azure Region which will be used for deployment."
  default     = "South Central US"
}

variable "username" {
  description = "Username for the VMs."
  default     = "dev007"
  type        = string
}

variable "password" {
  description = "The password for the VMs."
  default     = "Th151545tr0ngP455word"
  type        = string
}

variable "no_vms" {
  description = "The number of VMs to create."
  default     = 3
  type        = number
}