terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
  }
}
}

# provider "aws" {
#     region     = var.region
#     access_key = var.access_key
#     secret_key = var.secret_key
# }

provider "aws" {
  shared_config_files      = ["~/.aws/conf"]
  shared_credentials_files = ["~/.aws/credentials"]
  #profile                  = "default"
  region = "us-east-1"
}

resource aws_security_group "allow_ports"{
  description = "ports required for jenkins sonar and nexus"
  name = "allow_ports"
  vpc_id=var.vpc_id
  dynamic "ingress" {
    for_each = toset(var.ingress_sg_ports)
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

    dynamic "egress" {
      for_each= toset(var.egress_sg_port)
      iterator= port
      content {
        from_port = port.value
        to_port   = port.value
        protocol=  "-1"
        cidr_blocks=["0.0.0.0/0"]
      }
    }
    
  }