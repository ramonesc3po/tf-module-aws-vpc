provider "aws" {
  region = ""
}

module "vpc" {
  source = "../"

  organization = "zigzaga"

  cidr_vpc = "10.10.0.0/16"

  enable_public_subnet = "true"
  enable_private_subnet = "true"

  tags = {
    Tier = "production"
    Name = "zigzaga"
  }

  vpc_tags = {
    Teste = "teste"
  }
}