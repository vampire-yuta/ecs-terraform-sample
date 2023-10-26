module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.project}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}c", "${local.region}d"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  # [NOTE] PublicSubnetのみ作成している
  # single_nat_gateway = true
  enable_vpn_gateway = false
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count           = length(module.vpc.private_route_table_ids)
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = module.vpc.private_route_table_ids[count.index]
}

resource "aws_security_group" "vpc_endpoint" {
  name   = "vpc_endpoint_sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }
}
