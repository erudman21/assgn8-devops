output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.azs
}

output "sg_id" {
  value = module.bastion_sg.security_group_id
}

output "bastion_public_ip" {
  description = "The public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "ansible_controller_private_ip" {
  description = "The private IP of the Ansible controller"
  value       = aws_instance.ansible_controller.private_ip
}

output "amazon_linux_private_ips" {
  description = "Private IP addresses of the Amazon Linux servers"
  value       = aws_instance.amazon_linux_servers[*].private_ip
}

output "ubuntu_private_ips" {
  description = "Private IP addresses of the Ubuntu servers"
  value       = aws_instance.ubuntu_servers[*].private_ip
}

output "server_ips" {
  description = "Private IP addresses of the application servers"
  value = {
    amazon_linux = aws_instance.amazon_linux_servers[*].private_ip
    ubuntu = aws_instance.ubuntu_servers[*].private_ip
  }
}