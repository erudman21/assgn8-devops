packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ssh_public_key" {
  type    = string
}

source "amazon-ebs" "amazon_linux" {
  region         = var.aws_region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  instance_type  = "t2.micro"
  ssh_username   = "ec2-user"
  ami_name       = "assgn8-${formatdate("YYYYMMDDhhmmss", timestamp())}"
}

build {
  sources = ["source.amazon-ebs.amazon_linux"]

  provisioner "shell" {
    inline = [
      "sudo amazon-linux-extras install docker -y",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",
      "echo 'Docker installed successfully'"
    ]
  }

  provisioner "shell" {
    inline = [
      "mkdir -p ~/.ssh",
      "sh -c 'echo ${var.ssh_public_key} >> ~/.ssh/authorized_keys'",
      "chmod 700 ~/.ssh",
      "chmod 600 ~/.ssh/authorized_keys",
      "chown -R ec2-user:ec2-user ~/.ssh"
    ]
  }
}