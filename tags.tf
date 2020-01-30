variable "tags" {
  description = "Set tags to all resources"
  default     = {}
}

variable "vpc_tags" {
  description = "Additional vpc tags"
  default     = {}
}

variable "igw_tags" {
  description = "Additional igw tags"
  default     = {}
}

variable "public_route_table_tags" {
  description = "Additional public route table tags"
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional private route table tags"
  default     = {}
}

variable "intra_route_table_tags" {
  description = "Additional intra route table tags"
  default     = {}
}

variable "db_route_table_tags" {
  description = "Additional db route table tags"
  default     = {}
}

variable "wallet_route_table_tags" {
  description = "Additional wallet route table tags"
  default     = {}
}

variable "mgmt_route_table_tags" {
  description = "Additional mgmt route table tags"
  default     = {}
}

variable "mq_route_table_tags" {
  description = "Additional mq route table tags"
  default     = {}
}

variable "nat_eip_tags" {
  description = "Additional nat eip tags"
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Additional nat gateway tags"
  default     = {}
}

variable "dhcp_options_tags" {
  description = "Addtional dhcp_options tags"
  default     = {}
}

