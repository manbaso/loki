variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  type        = string
  default     = "ami-080e1f13689e07408"
}

variable "key_pair_name" {
  description = "The name of the EC2 key pair"
  type        = string
  default     = "project"
}

variable "log_group" {
  description = "The name of the EC2 key pair"
  type        = string
  default     = "cloudwatch-agent.log"
}


variable "log_stream" {
  type = map(any)
  default = {
    "cloudwatch-agent" = "cloudwatch-agent"
    "cloudwatch-test" = "cloudwatch-test"
    # "log_stream" = "log_stream"
  }
}
