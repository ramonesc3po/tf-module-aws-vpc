variable "tags" {
  description = "Set tags to all resources"
  type        = "map"

  default = {
    Terraform    = "true"
    Organization = "c3po"
  }
}

variable "vpc_tags" {
  description = "Additional vpc tags"
  type        = "map"
}
