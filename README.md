# assgn8-devops
# Overview
This project creates a custom AWS AMI with Packer in ```my_ami.pkr.hcl``` that includes:
- Amazon Linux
- Docker
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
- 6 EC2 instances distributed across the private subnets using the custom Packer AMI
- Key pairs for the SSH keys you want to use for the Bastion host and private EC2 instances

# Deploying
1. Make sure your AWS credentials are set in ```~/.aws/credentials```
2. Make sure Packer and Terraform are installed
3. Clone the repo
4. Set the public key you want to use for the private EC2 instances in ```packer-vars.pkrvars.hcl```, and optionally the aws region(defaults to us-east-1)

   Ex:
   ```
   ssh_public_key = "ssh-rsa AAA123123...."
   ```
6. Create the AMI:
   ```
   packer init my_ami.pkr.hcl
   packer build -var-file=packer-vars.pkrvars.hcl my_ami.pkr.hcl
   ```
   When that finishes you should now be able to see the AMI in AWS:
![image](https://github.com/user-attachments/assets/c916fb76-d067-4b84-8d23-2f78d45df069)
7. Set the public keys you want to use for your bastion host and private EC2 instances in ```terraform.tfvars```, and optionally any other values

   Ex:
   ```
   bastion_public_key = "ssh-rsa AAAA123123..."
   private_public_key = "ssh-rsa AAAA123123...."
   ```
8. Deploy:
   ```
   terraform init
   terraform plan
   terraform apply #-auto-approve if you want
   ```
   When that finishes you should now be able to see the EC2 instances running:
   ![image](https://github.com/user-attachments/assets/7309ac2b-52ff-4a49-8fec-b7e3de9363a1)

   
   Along with the appropriate VPC, security groups, etc... (with the appropriate ingress rules):
   ![image](https://github.com/user-attachments/assets/d8faaa83-e16a-49b4-90a1-8edebab90365)
9. To connect to the instances:
   - Add your ssh keys to ssh-agent
      ```
      eval $(ssh-agent)
      ssh-add PATH_TO_THE_BASTION_HOST_PRIVATE_KEY
      ssh-add PATH_TO_THE_PRIVATE_EC2S_PRIVATE_KEY
      ```
    - Connect to the bastion host using agent forwarding:
      ```
      ssh -A -i ~/path_to_bastion_host_private_key ec2-user@<BASTION_HOST_IP> # you can find this in the outputs from terraform apply or in AWS
      ```

   - Connect to a private EC2 instance from the bastion host:
     ```
     ssh ec2-user@<PRIVATE_EC2_PRIVATE_IP> # you can also find this in the outputs from terraform apply or in AWS
     ```

     Example:
     
     ![image](https://github.com/user-attachments/assets/b5f75c37-dcb4-4b32-a53d-07867c279a9b)



   
