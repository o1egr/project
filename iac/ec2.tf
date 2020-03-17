
provider "aws" {
        region = "us-east-2"
        }

resource "aws_instance" "Jenkins" {
        ami = "ami-0e38b48473ea57778"
        instance_type = "t2.micro"
        key_name = "Oleg"
        vpc_security_group_ids = [aws_security_group.Jenkins.id]
        subnet_id = "subnet-d8d4f9a2"

        tags = {
         Name = "Jenkins"
                }
}

resource "aws_instance" "Terraform" {
        ami = "ami-0e38b48473ea57778"
        instance_type = "t2.micro"
        key_name = "Oleg"
        vpc_security_group_ids = [aws_security_group.SSH.id]
        subnet_id = "subnet-d8d4f9a2"

        tags = {
         Name = "Terraform"
                }
}

resource "aws_instance" "Ansible" {
        ami = "ami-0e38b48473ea57778"
        instance_type = "t2.micro"
        key_name = "Oleg"
        vpc_security_group_ids = [aws_security_group.SSH.id]
        subnet_id = "subnet-d8d4f9a2"

        tags = {
         Name = "Ansible"
                }
}

resource "aws_security_group" "Jenkins" {
        name = "Jenkins 8080 22 security group"
        description = "Security group for jenkins master"

        dynamic "ingress" {
                for_each = ["8080", "22"]
                content {
                from_port = ingress.value
                to_port = ingress.value
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
                        }
}
        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
                }

}

resource "aws_security_group" "SSH" {
        name = "SSH security group"
        description = "Security group using ssh"

        dynamic "ingress" {
                for_each = ["22"]
                content {
                from_port = ingress.value
                to_port = ingress.value
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
                        }
}
        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
                }
}
