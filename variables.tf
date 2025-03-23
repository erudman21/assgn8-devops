variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Default region."
}

variable "bastion_public_key" {
  type        = string
  description = "The public key to access your bastion server"
}

variable "private_public_key" {
  type        = string
  description = "The public key to access your private instances"
}

variable "bastion_prefix"{
  type        = string
  default     = "assgn8-bastion"
  description = "Bastion prefix for the bastion resources"
}

variable "app_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for the application servers"
}

variable "vpc_name"{
  type        = string
  default     = "assgn8-vpc"
  description = "The name of the VPC" 
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR for the VPC"
}

variable "aws_azs" {
  description = "List of az in the specified region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "List of internal CIDR ranges for the private subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of internal CIDR ranges for the public subnet"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "project_name" {
  type        = string
  default     = "assgn8"
  description = "Name of the project"
}