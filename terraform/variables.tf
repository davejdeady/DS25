variable "region" {
   type = string
    description = "(Optional) The AWS region to deploy resources in."
    default = "eu-west-2" 
}

variable "vpc_id" {
  type        = string
  description = "(Optional) The VPC ID."
  default     = "vpc-0c2ce1661fe341745"
}

variable "subnet_ids" {
  type        = list(string)
  description = "(Optional) A list of public subnet IDs."
  default     = ["subnet-09e13ace1382c78e8","subnet-0e3fab8fcf6651f27"]
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "(Optional) A list of private subnet IDs."
  default     = ["subnet-0cdc2d94aaa64ce43","subnet-0942218f7f9d17113"]
}

variable "instance_ami" {
  type        = string
  description = "(Optional) The AMI ID for the EC2 instances."
  default     = "ami-02610cbccc9f5c013"
}

variable "project_name" {
  type        = string
  description = "(Optional) Project name"
  default     = "digital-summit"
}

variable "access_cidr_blocks" {
  type        = list(string)
  description = "(Optional) The CIDR block for the Security Group Ingress."
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = {
    project   = "digital summit 2025"
    owner     = "SP Engineering team"
  }
}

variable "capacity" {
  type = object({
    max_size         = number
    min_size         = number
    desired_capacity = number
  })

  default     = {
    max_size         = 6
    min_size         = 1
    desired_capacity = 3
  }
}