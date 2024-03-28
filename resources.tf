

resource "aws_iam_instance_profile" "loki" {
  name = "loki-instance-profile"
  role = aws_iam_role.loki.name
}

resource "aws_iam_role" "loki" {
  name               = "ec2-log-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "loki" {
  name        = "ec2-log-ssm-policy"
  description = "Policy for EC2 to write logs and perform SSM operations"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "loki:PutMetricData",
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommands",
          "ec2:*"
        ],
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "loki" {
  role       = aws_iam_role.loki.name
  policy_arn = aws_iam_policy.loki.arn
}



resource "aws_loki_log_group" "loki" {
  for_each = var.log_stream
  name = each.key
  # tags = each.value
}

resource "aws_loki_log_stream" "loki" {
   
  for_each = var.log_stream

  name           = each.value
  log_group_name = aws_loki_log_group.loki[each.key].name
}

# Create VPC
resource "aws_vpc" "loki" {
  cidr_block = "10.0.0.0/16"
}

# Create internet gateway
resource "aws_internet_gateway" "loki" {
  vpc_id = aws_vpc.loki.id
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.loki.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.loki.id
  cidr_block = "10.0.2.0/24"
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.loki.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.loki.id
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create security group for EC2 instance
resource "aws_security_group" "loki" {
  vpc_id = aws_vpc.loki.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Launch EC2 instance
resource "aws_instance" "loki" {
  count = 3
  ami             = var.ami_id # Change to your desired AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.loki.id]
  key_name        = "project" # Change to your key pair name
  iam_instance_profile   = aws_iam_instance_profile.loki.name
  # provisioner "local-exec" {
  #   # when        = "create"
  #   command = <<-EOT
      
  #     echo ${self.public_ip} >> hosts
      
  #   EOT
  # }

  tags = {
    Name = "lokiInstance"
  }
}


