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
  type      = string
  sensitive = true
}

source "amazon-ebs" "amazon_linux" {
  region         = var.aws_region
  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  instance_type  = "t2.micro"
  ssh_username   = "ec2-user"
  ami_name       = "assgn8-al-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  tags = {
    Name      = "OS: amazon"
  }
}

build {
  sources = ["source.amazon-ebs.amazon_linux"]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y docker",
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

source "amazon-ebs" "ubuntu" {
  region         = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type  = "t2.micro"
  ssh_username   = "ubuntu"
  ami_name       = "assgn8-ubuntu-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  tags = {
    Name      = "OS: ubuntu"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /tmp/docker.gpg",
      "sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg /tmp/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
      "sudo rm /tmp/docker.gpg",

      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \\\"$VERSION_CODENAME\\\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",
      "sudo systemctl status docker || echo 'Docker service not running correctly'",
      "docker --version || echo 'DOCKER NOT INSTALLED PROPERLY'"
    ]
  }

  provisioner "shell" {
    inline = [
      "mkdir -p ~/.ssh",
      "sh -c 'echo ${var.ssh_public_key} >> ~/.ssh/authorized_keys'",
      "chmod 700 ~/.ssh",
      "chmod 600 ~/.ssh/authorized_keys",
      "chown -R ubuntu:ubuntu ~/.ssh"
    ]
  }
}

source "amazon-ebs" "ubuntu_ansible" {
  region         = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type  = "t2.micro"
  ssh_username   = "ubuntu"
  ami_name       = "assgn8-ubuntu-ansible-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  tags = {
    Name      = "OS: ubuntu-ansible"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu_ansible"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates gnupg",
      "sudo apt-get update -y",
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get install -y ansible python3-pip jq",
      "sudo pip3 install boto3 botocore",
      "sudo mkdir -p /home/ubuntu/ansible",
      "sudo chown ubuntu:ubuntu /home/ubuntu/ansible"
    ]
  }

  provisioner "shell" {
    inline = [
      "mkdir -p ~/.ssh",
      "sh -c 'echo ${var.ssh_public_key} >> ~/.ssh/authorized_keys'",
      "chmod 700 ~/.ssh",
      "chmod 600 ~/.ssh/authorized_keys",
      "chown -R ubuntu:ubuntu ~/.ssh"
    ]
  }
}