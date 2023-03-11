terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "swarm" {
  cidr_block = "10.20.20.0/25"

  tags = {
    Name = "Trying-Docker-Swarm"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.swarm.id
  cidr_block        = "10.20.20.64/26"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Trying-Docker-Swarm-public"
  }
}

resource "aws_route_table" "swarm" {
  vpc_id = aws_vpc.swarm.id

  tags = {
    Name = "Trying-Docker-Swarm-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.swarm.id
}

resource "aws_internet_gateway" "swarm" {
  vpc_id = aws_vpc.swarm.id
  tags = {
    "Name" = "Trying-Docker-Swarm-1-gateway"
  }
}

resource "aws_route" "swarm" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.swarm.id
  gateway_id             = aws_internet_gateway.swarm.id
}

resource "aws_security_group" "swarm" {
  name        = "swarm_sg"
  description = "Basic webserver"
  vpc_id      = aws_vpc.swarm.id
}

resource "aws_vpc_security_group_ingress_rule" "swarm" {
  for_each = toset(var.ingress_ports)

  security_group_id = aws_security_group.swarm.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
}

resource "aws_vpc_security_group_egress_rule" "swarm" {
  for_each = toset(var.egress_ports)

  security_group_id = aws_security_group.swarm.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
}


resource "aws_network_interface" "swarm" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.swarm.id]

  tags = {
    Name = "Trying-Docker-Swarm-nic"
  }
}

resource "aws_eip" "swarm" {
  vpc               = true
  network_interface = aws_network_interface.swarm.id
  tags = {
    "Name" = "Trying-Docker-Swarm-ip"
  }
}

resource "aws_key_pair" "swarm" {
  key_name   = "swarm-key"
  public_key = file(var.public_key)
}

resource "aws_instance" "swarm_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "swarm-key"

  network_interface {
    network_interface_id = aws_network_interface.swarm.id
    device_index         = 0
  }

  tags = {
    Name = "Trying-Docker-Swarm"
  }
}


output "ec2_global_ips" {
  value = ["${aws_instance.swarm_host.*.public_ip}"]
}
