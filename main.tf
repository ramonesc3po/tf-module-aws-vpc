terraform {
  required_version = "<= 0.11.10"
}

locals {
  max_subnet_length = "${max(length(var.private_subnets), length(var.database_subnets))}"
  nat_gateway_count = "${var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length)}"
}

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
# Internet Gateway
##
resource "aws_internet_gateway" "this" {
  count = "${var.vpc_create && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(map("Name", format("%s", var.organization)), var.tags, var.igw_tags)}"
}

##
# NAT Gateway
##
locals {
  nat_gateway_ips = "${split(",", (var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))}"
}

resource "aws_eip" "nat" {
  count = "${var.vpc_create && (var.enable_nat_gateway && !var.reuse_nat_ips) ? local.nat_gateway_count : 0}"

  vpc = true

  tags = "${merge(map("Name", format("%s-%s", var.organization, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))),var.tags, var.nat_eip_tags)}"
}

resource "aws_nat_gateway" "this" {
  count = "${var.vpc_create && var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  allocation_id = "${element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(map("Name", format("%s-%s", var.organization, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))), var.tags, var.nat_gateway_tags)}"

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route" "private_nat_gateway" {
  count = "${var.vpc_create && var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"

  timeouts {
    create = "5m"
  }
}

##
# Public Routes
##
resource "aws_route_table" "public" {
  count = "${var.vpc_create && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}", var.organization)), var.tags, var.public_route_table_tags)}"
}

resource "aws_route" "public_igw" {
  count = "${var.vpc_create && length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

##
# Private routes
##
resource "aws_route_table" "private" {
  count = "${var.vpc_create && local.max_subnet_length > 0 ? local.nat_gateway_count : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(map("Name", (var.single_nat_gateway ? "${var.organization}-${var.private_subnet_suffix}" : format("%s-${var.private_subnet_suffix}-%s", var.organization, element(var.azs, count.index)))), var.tags, var.private_route_table_tags)}"
}

##
# MQ routes
##
resource "aws_route_table" "mq" {
  count = "${var.vpc_create && var.create_mq_route_table && length(var.mq_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, var.mq_route_table_tags, map("Name", "${var.organization}-${var.mq_subnet_suffix}"))}"
}

##
# Database routes
##
resource "aws_route_table" "db" {
  count = "${var.vpc_create && var.create_db_route_table && length(var.database_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, var.db_route_table_tags, map("Name", "${var.organization}-${var.database_subnet_suffix}"))}"
}

##
# Intra routes
##
resource "aws_route_table" "intra" {
  count = "${var.vpc_create && length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(map("Name", "${var.organization}-intra"), var.tags, var.intra_route_table_tags)}"
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

  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}-%s", var.organization, element(var.azs, count.index))), var.tags, var.public_subnet_tags)}"
}

resource "aws_subnet" "private" {
  count = "${var.vpc_create && length(var.private_subnets) > 0 ? length(var.azs) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(concat(var.private_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(map("Name", format("%s-${var.private_subnet_suffix}-%s", var.organization, element(var.azs, count.index))), var.tags, var.private_subnet_tags)}"
}

resource "aws_subnet" "intra" {
  count = "${var.vpc_create && length(var.intra_subnets) > 0 ? length(var.azs) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(concat(var.intra_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(map("Name", format("%s-${var.intra_subnet_suffix}-%s", var.organization, element(var.azs, count.index))), var.tags, var.intra_subnet_tags)}"
}

resource "aws_subnet" "database" {
  count = "${var.vpc_create && length(var.database_subnets) > 0 ? length(var.azs) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(concat(var.database_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(map("Name", format("%s-${var.database_subnet_suffix}-%s", var.organization, element(var.azs, count.index))), var.tags, var.database_subnet_tags)}"
}

resource "aws_subnet" "mq" {
  count = "${var.vpc_create && length(var.mq_subnets) > 0 ? length(var.azs) : 0}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(concat(var.mq_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

  tags = "${merge(map("Name", format("%s-${var.mq_subnet_suffix}-%s", var.organization, element(var.azs, count.index))), var.tags, var.mq_subnet_tags)}"
}

# Create once nat gateway if set false or create one nat gateway per subnet if set true


# Create route table per subnet


# Subnet association an route table

