locals {
  get_azs = "${data.aws_availability_zones.get_azs.names}"
}

# Get azs
data "aws_availability_zones" "get_azs" {}

##
# VPC
##
resource "aws_vpc" "this" {
  count = "${var.vpc_create == "true" ? 1 : 0}"

  cidr_block                       = "${var.cidr_vpc}"
  instance_tenancy                 = "${var.instance_tenancy}"
  enable_dns_support               = "${var.enable_dns_support}"
  enable_classiclink               = "${var.enable_classiclink}"
  assign_generated_ipv6_cidr_block = "${var.assign_generated_ipv6_cidr_block}"

  tags = "${merge(map("Name", format("%s", var.organization)), var.tags, var.vpc_tags)}"
}

##
# Subnets
##
resource "aws_subnet" "public" {
  count = "${var.vpc_create && length(var.public_subnets) > 0 ? length(var.azs) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(concat(var.public_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}-%s", var.organization, element(data.aws_availability_zones.get_azs.names, count.index))), var.tags, var.public_subnet_tags)}"
}

resource "aws_subnet" "private" {
  count = "${var.vpc_create && length(var.private_subnets) > 0 ? length(var.azs) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(concat(var.private_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(map("Name", format("%s-${var.private_subnet_suffix}-%s", var.organization, element(local.get_azs, count.index))), var.tags, var.private_subnet_tags)}"
}

resource "aws_subnet" "intra" {
  count = "${var.vpc_create && length(var.intra_subnets) > 0 ? length(var.azs) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(concat(var.intra_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(map("Name", format("%s-${var.intra_subnet_suffix}-%s", var.organization, element(local.get_azs, count.index))), var.tags, var.intra_subnet_tags)}"
}

resource "aws_subnet" "database" {
  count = "${var.vpc_create && length(var.database_subnets) > 0 ? length(var.azs) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(concat(var.database_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(map("Name", format("%s-${var.database_subnet_suffix}-%s", var.organization, element(local.get_azs, count.index))), var.tags, var.database_subnet_tags)}"
}

resource "aws_subnet" "mq" {
  count = "${var.vpc_create && length(var.mq_subnets) > 0 ? length(var.azs) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(concat(var.mq_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(map("Name", format("%s-${var.mq_subnet_suffix}-%s", var.organization, element(local.get_azs, count.index))), var.tags, var.mq_subnet_tags)}"
}

# Create ig once if set false or creat multiple ig if set true


# Create once nat gateway if set false or create one nat gateway per subnet if set true


# Create route table per subnet


# Subnet association an route table

