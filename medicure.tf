terraform {
 required_providers {
 aws = {
 source = "hashicorp/aws"
 version = "~> 5.0"
 }
 }
}
#configure provider
provider "aws" {
region = "us-east-1"
access_key = "AKIA5FTY62RMETXUHREP"
secret_key = "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"
}
#Configuration for Network Setup
# Creating a VPC
resource "aws_vpc" "medicure-vpc" {
cidr_block = "10.0.0.0/16"
}
# Create an Internet Gateway
resource "aws_internet_gateway" "medicure-ig" {
vpc_id = aws_vpc.medicure-vpc.id
tags = {
Name = "gateway1"
}
}
# Setting up the route table
resource "aws_route_table" "medicure-rt" {
vpc_id = aws_vpc.medicure-vpc.id
route {
# pointing to the internet
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.medicure-ig.id
}
route {
ipv6_cidr_block = "::/0"
gateway_id = aws_internet_gateway.medicure-ig.id
}
tags = {
Name = "rt1"
}
}
#Security Group Configuration
# Setting up the subnet
resource "aws_subnet" "medicure-subnet" {
vpc_id = aws_vpc.medicure-vpc.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-east-1a"
tags = {
Name = "subnet1"
}
}
# Associating the subnet with the route table
resource "aws_route_table_association" "medicure-rt-sub-assoc" {
subnet_id = aws_subnet.medicure-subnet.id
route_table_id = aws_route_table.medicure-rt.id
}
# Creating a Security Group
resource "aws_security_group" "medicure-sg" {
name = "medicure-sg"
description = "Enable web traffic for the medicureect"
vpc_id = aws_vpc.medicure-vpc.id
ingress {
description = "HTTPS traffic"
from_port = 443
to_port = 443
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
description = "HTTP traffic"
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
description = "SSH port"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
description = "SSH port"
from_port = 8082
to_port = 8082
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
}
tags = {
Name = "medicure-medicure-sg1"
}
}
# Creating a new network interface
resource "aws_network_interface" "medicure-ni" {
subnet_id = aws_subnet.medicure-subnet.id
private_ips = ["10.0.1.10"]
security_groups = [aws_security_group.medicure-sg.id]
}
# Attaching an elastic IP to the network interface
resource "aws_eip" "medicure-eip" {
vpc = true
network_interface = aws_network_interface.medicure-ni.id
associate_with_private_ip = "10.0.1.10"
}
# Creating test Ubuntu EC2 instance
resource "aws_instance" "test-instance" {
ami = "ami-053b0d53c279acc90"
instance_type = "t2.micro"
availability_zone = "us-east-1a"
key_name = "ubuntu-devops-ec2"
network_interface {
device_index = 0
network_interface_id = aws_network_interface.medicure-ni.id
}
user_data = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y docker.io
sudo apt install ansible
sudo apt install maven
EOF
tags = {
Name = "test-instance"
}
}

# Creating prod Ubuntu EC2 instance
resource "aws_instance" "prod-instance" {
ami = "ami-053b0d53c279acc90"
instance_type = "t2.micro"
availability_zone = "us-east-1a"
key_name = "ubuntu-devops-ec2"
network_interface {
device_index = 0
network_interface_id = aws_network_interface.medicure-ni.id
}
user_data = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y docker.io
sudo apt install ansible
sudo apt install maven
EOF
tags = {
Name = "prod-instance"
}
}
