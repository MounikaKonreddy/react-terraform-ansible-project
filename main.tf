terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "app_server1" {
  ami           = "ami-0e011417bd70948da"
  instance_type = "t4g.micro"
  key_name = "iac-demo-privatekey"
  security_groups = ["${aws_security_group.allow_all.name}"]

  tags = {
    Name = "AppServerInstance1"
  }
}


resource "null_resource" "nulllocal1"  {
provisioner "local-exec" {
            command = <<-EOT
      echo > inventory
      echo ${aws_instance.app_server1.public_dns} >> inventory
    EOT
    }
}

resource "aws_instance" "app_server2" {
  ami           = "ami-0e011417bd70948da"
  instance_type = "t4g.micro"
  key_name = "iac-demo-privatekey"
  security_groups = ["${aws_security_group.allow_all.name}"]


  tags = {
    Name = "AppServerInstance2"
  }
}

resource "null_resource" "nulllocal2"  {
provisioner "local-exec" {
            command = <<-EOT
      echo ${aws_instance.app_server2.public_dns} >> inventory
    EOT
    }
}
