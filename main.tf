# Create a VPC

resource "aws_vpc" "eng110-project-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "eng110-project-vpc"
  }
}