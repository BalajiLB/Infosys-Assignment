# AWS-Infra-Repo
This respository for provision aws resources.
Terraform use cases with AWS
Prerequisites
•	AWS free tier account
•	Terraform latest version
•	Checkov latest version to scan TF files vulnerabilities
•	GitHub account
•	Terragrunt latest version (Optional)

Notes: 
1.	Use remote backend S3 statefile and DynamoDB for statefile locking(Optional as latest Terraform version it is handled by S3)
2.	Test changes (terraform checkov, scan,init and plan) from local before pushing changes to github
3.	Terraform apply from local once plan is successful
4.	Use github action workflows to provision the resources (Ideal way of provisioning resources)
Use Case 1
Provision below resources in AWS:
1.	2 linux EC2 instances (one in us-west-2a and other in us-west-2b public subnets) to be provisioned in custom vpc subnets
2.	Install nginx and docker in both EC2 instances(through user data script or using provisioners)
3.	Custom VPC
4.	2 public subnets (one in us-west-2a AZ and other in us-west-2b AZ)
5.	Security group for both EC2(inbound 80,2 public subnet CIDR, outbound All 0.0.0.0/0)
6.	S3 bucket with versioning enabled

Modules to be created:
1.	EC2
2.	VPC
3.	Security Group
4.	S3



Use Case 2
Setup the infra provisioning pipelines in github workflows
Deploy pipeline to trigger manually/when change is pushed to master branch
Stages to include:
1.	git checkout
2.	checkov
3.	terraform init
4.	terraform plan
5.	terraform apply(on manual approval)
Destroy pipeline to trigger manually on need basis
Stages to include:
1.	git checkout
2.	terraform init
3.	terraform plan
4.	terraform destroy(on manual approval)














![image](https://github.com/user-attachments/assets/742fc5f0-4bb9-4a20-a0b6-164492fce48b)
