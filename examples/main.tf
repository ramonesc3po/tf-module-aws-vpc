provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::082715569515:role/vault-lab"
    session_name = "nb-test-zigzaga.com"
  }

  region = "us-east-1"
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "../"

  azs = "${data.aws_availability_zones.azs.names}"

  organization = "zigzaga"

  cidr_vpc = "10.10.0.0/16"

  public_subnets = "${cidrsubnet("10.10.0.0/16", 9, 504+length(${data.aws_availability_zones.azs.names}))}"
#  "${cidrsubnet(var.map_cidrvpc_nb-api[var.tier],9,496+count.index)}"
#  enable_private_subnet = true
#  enable_database_subnet = true
#  enable_mq_subnet = true
#  enable_intra_subnet = true


  tags = {
    Tier = "production"
    Organization = "zigzaga"
  }

  vpc_tags = {
    Teste = "teste"
  }
}
