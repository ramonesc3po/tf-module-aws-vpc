output "cidr_block_vpc" {
  description = "The cidr block of vpc"
  value       = "${element(concat(aws_vpc.this.*.cidr_block, list("")), 0)}"
}

output "" {
  value = ""
}
