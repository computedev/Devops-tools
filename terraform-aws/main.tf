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

data "aws_ami" "ubuntu" {
  # executable_users = ["self"]
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-*-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter{
  name="architecture"
  values=["x86_64"]
}
}



resource "aws_instance" "jenkins" {
  # ami           = var.launched== "False"?data.aws_ami.ubuntu.id : var.customami
  ami= var.cami_jen
  instance_type = "t2.micro"
  #instance_type="t2.small"
  vpc_security_group_ids = [aws_security_group.allow_ports.id]
  subnet_id = var.subnet_id
  private_ip = "10.0.1.40"
  key_name               = "key-all" #aws_key_pair.deployer.key_name
  associate_public_ip_address=true
  #user_data=file("../userdata/jenkins-setup.sh")

  
  tags={
      Name="JenkinsServer"
  }
}

output "PublicIP-jenkins" {
  value="${aws_instance.jenkins.public_ip}"
}

resource "aws_instance" "nexus" {
  ami = data.aws_ami.ubuntu.id
  # instance_type = "t2.micro"
  instance_type="t2.small"
  vpc_security_group_ids = [aws_security_group.allow_ports.id]
  subnet_id = var.subnet_id
  private_ip = "10.0.1.41"
  key_name               = "key-all" #aws_key_pair.deployer.key_name
  associate_public_ip_address=true
  user_data = file("../userdata/nexus-ubu.sh")

  tags={
      Name="nexus"
  }
}

output "PublicIP-nexus" {
  value="${aws_instance.nexus.public_ip}"
}

resource "aws_instance" "sonar" {
  ami = data.aws_ami.ubuntu.id
  #instance_type = "t2.micro"
  # instance_type="t2.small"
  instance_type="t2.medium"
  vpc_security_group_ids = [aws_security_group.allow_ports.id]
  subnet_id = var.subnet_id
  private_ip = "10.0.1.42"
  key_name               = "key-all" #aws_key_pair.deployer.key_name
  associate_public_ip_address=true
  user_data = file("../userdata/sonar-setup.sh")

  tags={
      Name="sonar"
  }
}

output "PublicIP-sonar" {
  value="${aws_instance.sonar.public_ip}"
}