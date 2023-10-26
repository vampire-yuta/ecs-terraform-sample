module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.project}-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["${local.region}a", "${local.region}c", "${local.region}d"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  single_nat_gateway = true

  # [NOTE] PublicSubnetのみ作成している
  enable_nat_gateway = false
  # single_nat_gateway = true
  enable_vpn_gateway = false
}
