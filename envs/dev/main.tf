
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source   = "../../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  env      = "dev"
}

module "alb" {
  source  = "../../modules/alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnet_ids
  env     = "dev"

  depends_on_igw = module.vpc.igw_dependency
}

module "ec2" {
  source    = "../../modules/ec2"
  subnet_id = module.vpc.public_subnet_ids[0]
  env       = "dev"
}
