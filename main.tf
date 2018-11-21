# Null resource
resource "null_resource" "subnet" {
  count = "${length(data.aws_availability_zones.get_azs.names)}"

  triggers {
    cidr_subnet_public = "${cidrsubnet(aws_vpc.create_vpc.cidr_block, 9, 504+count.index)}"
  }
}

# Get azs
data "aws_availability_zones" "get_azs" {}

# Create VPC and set default
resource "aws_vpc" "create_vpc" {
  count = "${var.vpc_create == "true" ? 1 : 0}"

  cidr_block                       = "${var.cidr_vpc}"
  instance_tenancy                 = "${var.instance_tenancy}"
  enable_dns_support               = "${var.enable_dns_support}"
  enable_classiclink               = "${var.enable_classiclink}"
  assign_generated_ipv6_cidr_block = "${var.assign_generated_ipv6_cidr_block}"

  tags = "${merge(map("Name", format("%s", var.organization)), var.tags, var.vpc_tags)}"
}

# Create subnets
resource "aws_subnet" "public" {
  count = "${length(data.aws_availability_zones.get_azs.names)}"

  vpc_id     = "${aws_vpc.create_vpc.id}"
  cidr_block = "${null_resource.subnet.triggers.cidr_subnet_public}"
}

# Create ig once if set false or creat multiple ig if set true


# Create once nat gateway if set false or create one nat gateway per subnet if set true


# Create route table per subnet


# Subnet association an route table

