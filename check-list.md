Sure! Here's a ready-to-use verify-list.md that you can directly upload to your GitHub repository:

markdown
Copy
Edit
# ✅ AWS EC2 Instance & Infrastructure Verification Checklist

---

## 🔐 1. Assume AWS Role for Terraform CLI Usage

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::055714170174:role/TerraformAdminRole \
  --role-session-name terraform-session
Set the assumed role for Terraform usage:

export AWS_PROFILE=terraform-admin
Run your Terraform plans:


terraform plan
🖥️ 2. EC2 Instance Verification - AWS CLI
a. List all EC2 instances and their current state

aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[InstanceId, State.Name]" \
  --output table
b. Verify Availability Zone for an instance

aws ec2 describe-instances --instance-ids <instance-id> \
  --query "Reservations[*].Instances[*].Placement.AvailabilityZone" \
  --output text
Example Output:

us-west-2a

c. List all instances with their Availability Zones

aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[InstanceId, Placement.AvailabilityZone]" \
  --output table
d. Get Instance ID, Private IP, and Public IP

aws ec2 describe-instances --instance-ids <instance-id> \
  --query "Reservations[*].Instances[*].[InstanceId, PrivateIpAddress, PublicIpAddress]" \
  --output table
Example Output:

InstanceId	PrivateIpAddress	PublicIpAddress
i-0273aaf1e1f29fd16	10.0.1.11	54.184.13.250

🔒 3. Security Group Verification
a. List Security Groups attached to the instance

aws ec2 describe-instances --instance-ids <instance-id> \
  --query "Reservations[*].Instances[*].SecurityGroups" \
  --output table
b. Describe Security Group inbound/outbound rules

aws ec2 describe-security-groups --group-ids <sg-id> --output table
Example Security Group Information:

Inbound: Allow TCP port 80 from 0.0.0.0/0

Outbound: Allow all traffic (0.0.0.0/0)

🏷️ 4. (Optional) Verify Tags on Instance
⚠️ Requires ec2:DescribeTags permission.
If not allowed, skip this step.

aws ec2 describe-tags --filters "Name=resource-id,Values=<instance-id>"\

```