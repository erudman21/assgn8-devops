#!/bin/bash

# Get the Ansible controller IP from Terraform output
CONTROLLER_IP=$(terraform output -raw ansible_controller_private_ip)
BASTION_IP=$(terraform output -raw bastion_public_ip)

mkdir -p ansible_files

cp configure_nodes.yml ansible_files/
cp inventory.aws_ec2.yml ansible_files/
cp ansible.cfg ansible_files/

# Put ansible_user in group_vars because it wasn't working in inventory.aws_ec2.yml
mkdir -p ansible_files/group_vars
cat > ansible_files/group_vars/tag_OS_amazon.yml << EOL
---
ansible_user: ec2-user
EOL

cat > ansible_files/group_vars/tag_OS_ubuntu.yml << EOL
---
ansible_user: ubuntu
EOL

echo "Created all Ansible files in ansible_files directory"

ssh -J ec2-user@$BASTION_IP ubuntu@$CONTROLLER_IP "mkdir -p ~/ansible"
scp -J ec2-user@$BASTION_IP -r ansible_files/* ubuntu@$CONTROLLER_IP:~/ansible/

ssh -J ec2-user@$BASTION_IP ubuntu@$CONTROLLER_IP "mkdir -p ~/.aws"
scp -J ec2-user@$BASTION_IP ~/.aws/credentials ubuntu@$CONTROLLER_IP:~/.aws/

echo "==== INSTRUCTIONS ===="
echo
echo "1. SSH to the controller:"
echo "   ssh -A -J ec2-user@$BASTION_IP ubuntu@$CONTROLLER_IP"
echo
echo "2. Run the Ansible playbook:"
echo "   cd ~/ansible && ansible-playbook -i inventory.aws_ec2.yml configure_nodes.yml -v"