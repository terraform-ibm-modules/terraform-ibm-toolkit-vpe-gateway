# Resource Group Variables
variable "resource_group_name" {
  type        = string
  description = "The name of the IBM Cloud resource group where the VPC gateways will be created."
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where the cluster will be/has been installed."
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api token"
}

variable "name_prefix" {
  type        = string
  description = "The name of the vpc resource"
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "The id of the vpc instance"
}

variable "vpc_subnet_count" {
  type        = number
  description = "Number of vpc subnets"
}

variable "vpc_subnets" {
  type        = list(object({
    label = string
    id    = string
    zone  = string
  }))
  description = "List of subnets with labels"
}

variable "resource_label" {
  type        = string
  description = "The label for the resource to which the vpe will be connected. Used as a tag and as part of the vpe name."
}

variable "resource_crn" {
  type        = string
  description = "The crn of the resource to which the vpe will be connected."
}

variable "resource_service" {
  type        = string
  description = "The endpoint gateway target resource type. Values can be provider_cloud_service, provider_infrastructure_service, ?."
  default     = "provider_cloud_service"
}
