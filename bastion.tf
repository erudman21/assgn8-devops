resource "aws_key_pair" "bastion-key" {
  key_name   = "bastion-key"
  public_key = var.bastion_public_key
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 5.0"

  name        = "bastion-sg"
  description = "Security group for the bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [local.public_ip]
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion-key.key_name
  vpc_security_group_ids = [module.bastion_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Name      = "${var.bastion_prefix}-host"
    Terraform = "true"
  }
}