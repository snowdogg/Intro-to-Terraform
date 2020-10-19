# AWS VPC and EC2 with Terraform

## Setup

This setup is for Mac OS, but would also work on a Linux machine.

You should have AWS CLI installed on your machine and have run and configured the AWS CLI for the account or IAM role you wish to use to deploy these resources with this command: 
```bash
aws config
```
See AWS documentation for more information.

### Download and Install Terrafrom
https://www.terraform.io/

The following command should return Terraform v0.13.4, the latest version of Terraform at time of writing:
```bash
terraform -v
```

### How to set up this project

Navigate to project's root folder and enter in terminal: 
```bash
terraform init
```

Then, open main.tf in a text editor find the value of public_key in the aws_key_pair resource named "default", and replace with your public key's string. 

#### Run terraform plan to see what resources will be created
```bash
terraform plan
```

#### Run Terraform Apply 
Run terraform apply to apply your configuration and launch resources in the cloud
```bash
terraform apply
```
After this command finishes you should see a public ip that Terraform spits out on the terminal. Copy this. Then you can ssh into your instance. Let's say for example your private key is called "MyKey.pem" and is stored in the downloads folder of a mac. Let's also assume that your public ip that Terraform informed you of is 9.9.9.9. You would then use this ssh commmand to access the command line of your instance: 
```bash
ssh -i ~/Downloads/MyKey.pem ubuntu@9.9.9.9
```

Logout of your EC2 instance. Run Terraform State to see the state of your resources.

#### Run Terraform DESTROY!!! IMPORTANT
Use terraform destroy to kill all resources. This is important so you don't leave a bunch of resources running and accidentally rack up a bill. That being said, everything in this project SHOULD be in the free tier but I cannot be responsible if it isn't.

That's All Folks!

