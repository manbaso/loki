# data "aws_vpc" "cloudwatch" {
#   cidr_block = "10.0.0.0/16"
# }


data "aws_key_pair" "cloudwatch" {
  key_name = "project"  # Specify the name of your SSH key pair
}