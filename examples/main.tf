provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::082715569515:role/vault-lab"
    session_name = "nb-test-zigzaga.com"
  }

  region = "us-east-1"
}

data "aws_availability_zones" "azs" {}

resource "null_resource" "let_subnet" {
  count = "${length(data.aws_availability_zones.azs.names)}"

  triggers {
    public_subnets   = "${cidrsubnet("10.10.0.0/16", 9, 504+count.index)}"
    private_subnets  = "${cidrsubnet("10.10.0.0/16", 9,496+count.index)}"
    intra_subnets    = "${cidrsubnet("10.10.0.0/16", 7, count.index)}"
    mq_subnets       = "${cidrsubnet("10.10.0.0/16", 7, 116+count.index)}"
    database_subnets = "${cidrsubnet("10.10.0.0/16", 7, 118+count.index)}"
  }
}

module "vpc" {
  source = "../"

  azs = "${data.aws_availability_zones.azs.names}"

  organization = "zigzaga"

  cidr_vpc = "10.10.0.0/16"

  public_subnets   = "${null_resource.let_subnet.*.triggers.public_subnets}"
  private_subnets  = "${null_resource.let_subnet.*.triggers.private_subnets}"
  intra_subnets    = "${null_resource.let_subnet.*.triggers.intra_subnets}"
  mq_subnets       = "${null_resource.let_subnet.*.triggers.mq_subnets}"
  database_subnets = "${null_resource.let_subnet.*.triggers.database_subnets}"

  tags = {
    Tier         = "production"
    Organization = "zigzaga"
  }

  vpc_tags = {
    Teste = "teste"
  }
}
