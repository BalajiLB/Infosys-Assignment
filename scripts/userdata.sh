#!/bin/bash
# Update the OS
yum update -y

# Install Nginx
amazon-linux-extras enable nginx1
yum install -y nginx
systemctl enable nginx
systemctl start nginx

# Install Docker
amazon-linux-extras enable docker
yum install -y docker
systemctl enable docker
systemctl start docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Optional: Create a sample HTML page
#echo "<h1>Deployed via User Data on $(hostname)</h1>" > /usr/share/nginx/html/index.html
