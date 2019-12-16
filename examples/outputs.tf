output "public_subnet" {
  value = null_resource.let_subnet.*.triggers.public_subnets
}

output "private_subnet" {
  value = null_resource.let_subnet.*.triggers.private_subnets
}

output "intra_subnet" {
  value = null_resource.let_subnet.*.triggers.intra_subnets
}

output "mq_subnet" {
  value = null_resource.let_subnet.*.triggers.mq_subnets
}

output "database_subnet" {
  value = null_resource.let_subnet.*.triggers.database_subnets
}
