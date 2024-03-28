# # Define provider
# provider "aws" {
#   region = "us-east-1" # Change to your desired region
# }

# # Create VPC
# resource "aws_vpc" "cloudwatch" {
#   cidr_block = "10.0.0.0/16"
# }

# # Create internet gateway
# resource "aws_internet_gateway" "cloudwatch" {
#   vpc_id = aws_vpc.cloudwatch.id
# }

# # Create public subnet
# resource "aws_subnet" "public" {
#   vpc_id                  = aws_vpc.cloudwatch.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = true
# }

# # Create private subnet
# resource "aws_subnet" "private" {
#   vpc_id     = aws_vpc.cloudwatch.id
#   cidr_block = "10.0.2.0/24"
# }

# # Create route table for public subnet
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.cloudwatch.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.cloudwatch.id
#   }
# }

# # Associate public subnet with public route table
# resource "aws_route_table_association" "public" {
#   subnet_id      = aws_subnet.public.id
#   route_table_id = aws_route_table.public.id
# }

# # Create security group for EC2 instance
# resource "aws_security_group" "cloudwatch" {
#   vpc_id = aws_vpc.cloudwatch.id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Launch EC2 instance
# resource "aws_instance" "cloudwatch" {
#   ami             = var.ami_id # Change to your desired AMI
#   instance_type   = "t2.micro"
#   subnet_id       = aws_subnet.public.id
#   security_groups = [aws_security_group.cloudwatch.name]
#   key_name        = "project" # Change to your key pair name
#   iam_instance_profile   = aws_iam_instance_profile.cloudwatch.name
#   provisioner "local-exec" {
#     # when        = "create"
#     command = <<-EOT
#       sleep 60
#       echo "" > hosts
#       echo "[server]" >> hosts
#       echo ${self.public_ip} >> hosts
#       ansible-playbook -i hosts playbook.yml
#     EOT
#   }

#   tags = {
#     Name = "cloudwatchInstance"
#   }
# }
