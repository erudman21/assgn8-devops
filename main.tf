provider "aws" {
  region = var.aws_region
}

data "http" "public_ip" {
  url = "https://api.ipify.org"
}

locals {
  public_ip = "${chomp(data.http.public_ip.response_body)}/32"
}

data "aws_ami" "custom_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["assgn8-*"]
  }
}

resource "aws_key_pair" "private-key" {
  key_name   = "private-key"
  public_key = var.private_public_key
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  
  name = var.vpc_name
  cidr = var.vpc_cidr
  
  azs             = var.aws_azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  
  tags = {
    Terraform   = "true"
    Project     = var.project_name
  }
}

module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "private-sg"
  description = "Security group for application servers in private subnet"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]
  
  egress_rules = ["all-all"]
}

resource "aws_instance" "app_servers" {
  count                  = 6
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.app_instance_type
  vpc_security_group_ids = [module.private_sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[count.index % length(module.vpc.private_subnets)]
  key_name               = aws_key_pair.private-key.key_name
  
  tags = {
    Name        = "${var.project_name}-app-server-${count.index + 1}"
    Terraform   = "true"
  }
}