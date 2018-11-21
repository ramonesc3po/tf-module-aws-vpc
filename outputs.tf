output "cidr_block_vpc" {
  description = "The cidr block of vpc"
  value       = "${element(concat(aws_vpc.create_vpc.*.cidr_block, list("")), 0)}"
}

  output "" {
  value = ""
}
