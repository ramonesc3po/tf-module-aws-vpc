locals {
  max_subnet_length = max(length(var.private_subnets), length(var.database_subnets),length(var.wallet_subnets))
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
  compose_vpc_name  = "${var.organization}-${var.name}"
  vpc_default_name  = var.organization
  vpc_name          = var.name != "" ? local.compose_vpc_name : local.vpc_default_name
}

##
# VPC
##
resource "aws_vpc" "this" {
  count = var.vpc_create == "true" ? 1 : 0

  cidr_block                       = var.cidr_vpc
  instance_tenancy                 = var.instance_tenancy
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_classiclink               = var.enable_classiclink
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge(
    {
      Name = format("%s", local.vpc_name)
    },
    var.tags,
    var.vpc_tags,
  )
}

##
# DHCP OPTIONS
##
resource "aws_vpc_dhcp_options" "this" {
  count = var.vpc_create && var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    {
      Name = format("%s", var.organization)
    },
    var.tags,
    var.dhcp_options_tags,
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.vpc_create && var.enable_dhcp_options ? 1 : 0

  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
  vpc_id          = aws_vpc.this[0].id
}

##
# Internet Gateway
##
resource "aws_internet_gateway" "this" {
  count = var.vpc_create && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = format("%s", var.organization)
    },
    var.tags,
    var.igw_tags,
  )
}

##
# NAT Gateway
##
locals {
  nat_gateway_ips = split(
    ",",
    var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id),
  )
}

resource "aws_eip" "nat" {
  count = var.vpc_create && var.enable_nat_gateway && false == var.reuse_nat_ips ? local.nat_gateway_count : 0

  vpc = true

  tags = merge(
    {
      Name = format(
        "%s-%s",
        var.organization,
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )
}

resource "aws_nat_gateway" "this" {
  count = var.vpc_create && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      Name = format(
        "%s-%s",
        var.organization,
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count = var.vpc_create && var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

##
# Public Routes
##
resource "aws_route_table" "public" {
  count = var.vpc_create && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = format("%s-${var.public_subnet_suffix}", var.organization)
    },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route" "public_igw" {
  count = var.vpc_create && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

##
# Private routes
##
resource "aws_route_table" "private" {
  count = var.vpc_create && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = var.single_nat_gateway ? "${var.organization}-${var.private_subnet_suffix}" : format(
        "%s-${var.private_subnet_suffix}-%s",
        var.organization,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.private_route_table_tags,
  )
}

##
# MQ routes
##
resource "aws_route_table" "mq" {
  count = var.vpc_create && var.create_mq_route_table && length(var.mq_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    var.mq_route_table_tags,
    {
      Name = "${var.organization}-${var.mq_subnet_suffix}"
    },
  )
}

##
# Database routes
##
resource "aws_route_table" "db" {
  count = var.vpc_create && var.create_db_route_table && length(var.database_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    var.db_route_table_tags,
    {
      Name = "${var.organization}-${var.database_subnet_suffix}"
    },
  )
}

##
# Wallet routes
##
resource "aws_route_table" "wallet" {
  count = var.vpc_create && var.create_wallet_route_table && length(var.wallet_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    var.wallet_route_table_tags,
    {
      Name = "${var.organization}-${var.wallet_subnet_suffix}"
    },
  )
}

##
# Mgmt routes
##
resource "aws_route_table" "mgmt" {
  count = var.vpc_create && var.create_mgmt_route_table && length(var.mgmt_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
  var.tags,
  var.mgmt_route_table_tags,
  {
    Name = "${var.organization}-${var.mgmt_subnet_suffix}"
  },
  )
}

##
# Intra routes
##
resource "aws_route_table" "intra" {
  count = var.vpc_create && length(var.intra_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = "${var.organization}-intra"
    },
    var.tags,
    var.intra_route_table_tags,
  )
}

##
# Subnets
##
resource "aws_subnet" "public" {
  count = var.vpc_create && length(var.public_subnets) > 0 ? length(var.azs) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = format(
        "%s-${var.public_subnet_suffix}-%s",
        var.organization,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
}

resource "aws_subnet" "private" {
  count = var.vpc_create && length(var.private_subnets) > 0 ? length(var.azs) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = element(concat(var.private_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format(
        "%s-${var.private_subnet_suffix}-%s",
        var.organization,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.private_subnet_tags,
  )
}

resource "aws_subnet" "intra" {
  count = var.vpc_create && length(var.intra_subnets) > 0 ? length(var.azs) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = element(concat(var.intra_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format(
        "%s-${var.intra_subnet_suffix}-%s",
        var.organization,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.intra_subnet_tags,
  )
}

resource "aws_subnet" "database" {
  count = var.vpc_create && length(var.database_subnets) > 0 ? length(var.azs) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = element(concat(var.database_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format(
        "%s-${var.database_subnet_suffix}-%s",
        var.organization,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.database_subnet_tags,
  )
}

resource "aws_subnet" "wallet" {
  count = var.vpc_create && length(var.wallet_subnets) > 0 ? length(var.azs) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = element(concat(var.wallet_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format(
        "%s-${var.wallet_subnet_suffix}-%s",
        var.organization,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.wallet_subnet_tags,
  )
}

resource "aws_subnet" "mgmt" {
  count = var.vpc_create && length(var.mgmt_subnets) > 0 ? length(var.azs) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = element(concat(var.mgmt_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
  {
    Name = format(
    "%s-${var.mgmt_subnet_suffix}-%s",
    var.organization,
    element(var.azs, count.index),
    )
  },
  var.tags,
  var.mgmt_subnet_tags,
  )
}


resource "aws_subnet" "mq" {
  count = var.vpc_create && length(var.mq_subnets) > 0 ? length(var.azs) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = element(concat(var.mq_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format(
        "%s-${var.mq_subnet_suffix}-%s",
        var.organization,
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.mq_subnet_tags,
  )
}

##
# Subnet Association
##
resource "aws_route_table_association" "public" {
  count = var.vpc_create && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  route_table_id = element(aws_route_table.public.*.id, count.index)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count = var.vpc_create && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  route_table_id = element(
    aws_route_table.private.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(aws_subnet.private.*.id, count.index)
}

resource "aws_route_table_association" "intra" {
  count = var.vpc_create && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0

  route_table_id = element(aws_route_table.intra.*.id, 0)
  subnet_id      = element(aws_subnet.intra.*.id, count.index)
}

resource "aws_route_table_association" "database" {
  count = var.vpc_create && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  route_table_id = element(
    coalescelist(aws_route_table.db.*.id, aws_route_table.private.*.id),
    var.single_nat_gateway || var.create_db_route_table ? 0 : count.index,
  )
  subnet_id = element(aws_subnet.database.*.id, count.index)
}

resource "aws_route_table_association" "wallet" {
  count = var.vpc_create && length(var.wallet_subnets) > 0 ? length(var.wallet_subnets) : 0

  route_table_id = element(
    coalescelist(aws_route_table.wallet.*.id, aws_route_table.private.*.id),
    var.single_nat_gateway || var.create_wallet_route_table ? 0 : count.index,
  )
  subnet_id = element(aws_subnet.wallet.*.id, count.index)
}

resource "aws_route_table_association" "mgmt" {
  count = var.vpc_create && length(var.mgmt_subnets) > 0 ? length(var.mgmt_subnets) : 0

  route_table_id = element(
  coalescelist(aws_route_table.mgmt.*.id, aws_route_table.private.*.id),
  var.single_nat_gateway || var.create_mgmt_route_table ? 0 : count.index,
  )
  subnet_id = element(aws_subnet.mgmt.*.id, count.index)
}


resource "aws_route_table_association" "mq" {
  count = var.vpc_create && length(var.mq_subnets) > 0 ? length(var.mq_subnets) : 0

  route_table_id = element(
    coalescelist(aws_route_table.mq.*.id, aws_route_table.private.*.id),
    var.single_nat_gateway || var.create_mq_route_table ? 0 : count.index,
  )
  subnet_id = element(aws_subnet.mq.*.id, count.index)
}

