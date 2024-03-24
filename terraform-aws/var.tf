variable "region" {
    description = "The region where the resources will be created."
    type = string
    default = "us-east-1"
  
}

variable "access_key" {
    description = "AWS access key for an account with enough privileges to create resources in AWS."
    type = string
    default = "~/.aws/credentials"
  
}

variable "secret_key" {
    description = "Secret key corresponding to the provided AWS access key."
    type= string
    sensitive = true
    default = "~/.aws/credentials"
    }

variable "ingress_sg_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22,80, 8080,443,9001,9000]
}

variable "egress_sg_port" {
  type = list(number)
  description = "egress"
  default = [0]
  
}


variable "subnet_id" {
  type        = string
  description = "VPC ID where the security"
  default     = "subnet-08dc85862f4903222"

}

variable "vpc_id" {
  type        = string
  description = "vpc id"
  default     = ""
  

}

variable "launched" {
    type        = bool
    default = true
}
variable "customami" {
    type = string
    default = ""
  
}
  