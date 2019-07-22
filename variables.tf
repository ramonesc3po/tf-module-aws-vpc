variable "azs" {
  description = "Define availability zone"
  default     = []
}

variable "name" {
  description = "add custom name vpc"
  default     = ""
}

variable "organization" {
  description = "Define name all resources"
  type        = string
  default     = "megastructure"
}

variable "vpc_create" {
  description = "Set the true for create vpc or false no create a new vpc"
  type        = string
  default     = "true"
}

variable "cidr_vpc" {
  description = "Set the cidr block for a new vpc"
  type        = string
}

variable "instance_tenancy" {
  description = "Set default vpc"
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "Set support DNS"
  default     = "false"
}

variable "enable_dns_hostnames" {
  description = "Set support hostnames DNS"
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

##
# DHCP OPTIONS
##
variable "enable_dhcp_options" {
  description = "Should be true if you want create dhcp options"
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Set Domain Name"
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Set a list of DNS server addresses for DHCP options set, default AWS provided"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios server for DHCP options set"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set"
  default     = ""
}

###
# Subnets
###

variable "public_subnets" {
  description = "Should be true if you want create public subnets calculate with all azs in the region"
  default     = []
}

variable "private_subnets" {
  description = "Should be true if you want create private subnets calculate with all azs in the region"
  default     = []
}

variable "intra_subnets" {
  description = "Should be true if you want create intra subnets calculate with all azs in the region"
  default     = []
}

variable "database_subnets" {
  description = "Should be true if you want create database subnets calculate with all azs in the region"
  default     = []
}

variable "wallet_subnets" {
  description = "Should be true if you want create wallet subnets calculate with all azs in the region"
  default     = []
}

variable "mq_subnets" {
  description = "Should be true if you want create mq subnets calculate with all azs in the region"
  default     = []
}

variable "public_subnet_suffix" {
  description = "Suffix name public subnet"
  default     = "public"
}

variable "private_subnet_suffix" {
  description = "Suffix name private subnet"
  default     = "private"
}

variable "intra_subnet_suffix" {
  description = "Suffix name intra subnet"
  default     = "intra"
}

variable "database_subnet_suffix" {
  description = "Suffix name database subnet"
  default     = "database"
}

variable "wallet_subnet_suffix" {
  description = "Suffix name wallet subnet"
  default     = "wallet"
}

variable "mq_subnet_suffix" {
  description = "Suffix name mq subnet"
  default     = "mq"
}

variable "public_subnet_tags" {
  description = "Additional tags in public subnets"
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags in private subnets"
  default     = {}
}

variable "intra_subnet_tags" {
  description = "Additional tags in intra subnets"
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags in database subnets"
  default     = {}
}

variable "wallet_subnet_tags" {
  description = "Additional tags in wallet subnets"
  default     = {}
}

variable "mq_subnet_tags" {
  description = "Additional tags in mq subnets"
  default     = {}
}

##
# Route Table
##
variable "create_db_route_table" {
  description = "Create route table database subnet"
  default     = false
}

variable "create_wallet_route_table" {
  description = "Create route table wallet subnet"
  default     = false
}

variable "create_mq_route_table" {
  description = "Create route table mq subnet"
  default     = false
}

##
# Internet gateway and NAT
##
variable "single_nat_gateway" {
  description = "Create once nat gateway"
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Create one nat gaterway per az"
  default     = false
}

variable "enable_nat_gateway" {
  description = "Should true you want create nat gateway"
  default     = false
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  default     = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}

