variable "organization" {
  description = "Define name all resources"
  type        = "string"
  default     = "megastructure"
}

variable "vpc_create" {
  description = "Set the true for create vpc or false no create a new vpc"
  type        = "string"
  default     = "true"
}

variable "cidr_vpc" {
  description = "Set the cidr block for a new vpc"
  type        = "string"
}

variable "instance_tenancy" {
  description = "Set default vpc"
  type        = "string"
  default     = "default"
}

variable "enable_dns_support" {
  description = "Set support DNS"
  default     = "false"
}

variable "enable_classiclink" {
  description = "Set enable classiclink"
  default     = "false"
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Enable generate ipv6 cidr block"
  default     = "false"
}

variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  default     = "[]"
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = "true"
}

###
# Subnets
###

variable "enable_public_subnet" {
  description = "Should be true if you want create public subnets calculate with all azs in the region"
  default     = "false"
}

variable "enable_private_subnet" {
  description = "Should be true if you want create private subnets calculate with all azs in the region"
  default     = "false"
}

variable "public_subnet_suffix" {
  description = "Suffix name public subnet"
  default     = "public"
}

variable "private_subnet_suffix" {
  description = "Suffix name private subnet"
  default     = "private"
}

variable "public_subnet_tags" {
  description = "Additional tags in public subnets"
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags in private subnets"
  default     = {}
}