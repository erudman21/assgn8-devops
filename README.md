# Assignment 8
# Overview
This project creates 3 custom AWS AMIs with Packer in ```my_amis.pkr.hcl``` that includes:
- Amazon Linux with:
    - Docker
    - Your SSH public key
- Ubuntu with:
    - Docker
    - Your SSH public key
- Ubuntu for Ansible with:
    - Ansible
    - Python
    - Your SSH public key

Along with this, this repo has Terraform files to create:
- A VPC
- 3 private subnets
- 1 public subnet
- A security group for private EC2 instances
    - Ingress rule:
        - SSH-TCP from the security group for the bastion host
- A security group for a bastion host/public instances
    - Ingress rule:
        - SSH-TCP from the IP of the machine calling terraform apply
- A bastion host in the public subnet
- 6 EC2 instances distributed across the private subnets using the custom Packer AMIs
    - 3 are Amazon Linux, 3 are Ubuntu
- An EC2 instance meant to be the Ansible Controller
- Key pairs for the SSH keys you want to use for the Bastion host and private EC2 instances

And Ansible files:
- ```configure_nodes.yml``` - playbook
- ```inventory.aws_ec2.yml``` - inventory
- ```ansible.cfg``` - config
- ```setup_controller.sh``` - script to scp and setup ansible files on controller

# Deploying
1. Make sure your AWS credentials are set in ```~/.aws/credentials```
2. Make sure Packer and Terraform are installed
3. Clone the repo
4. Set the public key you want to use for the private EC2 instances in ```packer-vars.pkrvars.hcl```, and optionally the aws region(defaults to us-east-1)

   Ex:
   ```
   ssh_public_key = "ssh-rsa AAA123123...."
   ```
5. Create the AMI:
   ```
   packer init my_amis.pkr.hcl
   packer build -var-file=packer-vars.pkrvars.hcl my_amis.pkr.hcl
   ```
   When that finishes you should now be able to see the AMIs in AWS with the appropriate tags:
   
   ![Screenshot 2025-03-30 194748](https://github.com/user-attachments/assets/10150dd5-f55e-48b6-887b-2961158de84e)
   
6. Set the public keys you want to use for your bastion host and private EC2 instances in ```terraform.tfvars```, and optionally any other values

   Ex:
   ```
   bastion_public_key = "ssh-rsa AAAA123123..."
   private_public_key = "ssh-rsa AAAA123123...."
   ```
7. Deploy:
   ```
   terraform init
   terraform plan
   terraform apply #-auto-approve if you want
   ```
   When that finishes you should now be able to see the EC2 instances running:
   
   ![Screenshot 2025-03-30 231318](https://github.com/user-attachments/assets/98173860-4241-4bb0-9474-3fa2a73598de)

   
   Along with the appropriate VPC, security groups, etc... (with the appropriate ingress rules):
   ![image](https://github.com/user-attachments/assets/d8faaa83-e16a-49b4-90a1-8edebab90365)
8. Make sure your SSH keys are added to ssh-agent:
   - Add your ssh keys to ssh-agent
      ```
      eval $(ssh-agent)
      ssh-add PATH_TO_THE_BASTION_HOST_PRIVATE_KEY
      ssh-add PATH_TO_THE_PRIVATE_EC2S_PRIVATE_KEY
      ```
9. Setup controller:
   ```
   chmod +x setup_controller.sh
   ./setup_controller.sh
   ```

   This will create an ansible_files directory and scp the files to the controller EC2. You will need to accept the SSH hosts/connections.
   This will also print out the instructions to run the ansible playbook with the appropriate controller and bastion host IPs filled in like:
   
   ![Screenshot 2025-03-30 195437](https://github.com/user-attachments/assets/e1a3cda5-b8b2-48df-b6fc-9b43125a4b81)

10. Run the output commands from the script

   After you run the playbook it should:
   - Update and upgrade the packages (if needed)
   - Verify we are running the latest docker
   - Report the disk usage for each ec2 instance
  
   Like this:
    ![Screenshot 2025-03-30 230324](https://github.com/user-attachments/assets/e54e94d5-0694-4e63-becf-c327cad03c25)
    ![Screenshot 2025-03-30 230216](https://github.com/user-attachments/assets/46e8f0df-4e5f-4154-b697-c1efd4c42dcb)



   
