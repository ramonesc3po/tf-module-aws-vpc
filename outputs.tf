output "cidr_block_vpc" {
  description = "The cidr block of vpc"
  value       = "${element(concat(aws_vpc.this.*.cidr_block, list("")), 0)}"
}

output "vpc_id" {
  description = "The vpc id"
  value       = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
}

output "subnets_private_cidr_blocks" {
  description = "Show all subnets cidr blocks private"
  value = "${aws_subnet.private.*.cidr_block}"
}

output "subnets_database_cidr_blocks" {
  description = "Show all subnets cidr blocks database"
  value = "${aws_subnet.database.*.cidr_block}"
}

output "subnets_wallet_cidr_blocks" {
  description = "Show all subnets cidr blocks wallet"
  value = "${aws_subnet.wallet.*.cidr_block}"
}

output "subnets_public_cidr_blocks" {
  description = "Show all subnets cidr blocks public"
  value = "${aws_subnet.public.*.cidr_block}"
}

output "subnets_mq_cidr_blocks" {
  description = "Show all subnets cidr blocks mq"
  value = "${aws_subnet.mq.*.cidr_block}"
}

output "subnets_intra_cidr_blocks" {
  description = "Show all subnets cidr blocks intra"
  value = "${aws_subnet.intra.*.cidr_block}"
}

output "subnets_private_ids" {
  description = "Show all private ids"
  value = "${aws_subnet.private.*.id}"
}

output "subnets_public_ids" {
  description = "Show all public ids"
  value = "${aws_subnet.public.*.id}"
}

output "subnets_intra_ids" {
  description = "Show all intra ids"
  value = "${aws_subnet.intra.*.id}"
}

output "subnets_wallet_ids" {
  description = "Show all wallet ids"
  value = "${aws_subnet.wallet.*.id}"
}

output "subnets_mq_ids" {
  description = "Show all mq ids"
  value = "${aws_subnet.mq.*.id}"
}

output "subnets_database_ids" {
  description = "Show all database ids"
  value = "${aws_subnet.database.*.id}"
}

output "route_table_public_ids" {
  value = "${aws_route_table.public.*.id}"
}

output "nat_gw" {
  value = "${element(concat(aws_nat_gateway.this.*.public_ip, list("")), local.nat_gateway_count)}"
}
