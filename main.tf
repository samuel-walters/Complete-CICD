# Variable blocks (these variables are assigned values in jenkins)

variable "vpc_cidr"{}
variable "nacl_cidr_block"{}
variable "subnet_cidr"{}
variable "availability_zone_aws"{}
variable "security_cidr"{}
variable "security_port1"{}
variable "security_port2"{}
variable "security_port3"{}
variable "security_port4"{}
variable "security_port5"{}
variable "security_port6"{}
variable "security_port7"{}
variable "security_port8"{}
variable "security_port9"{}
variable "security_port10"{}
variable "security_port11"{}
variable "security_port12"{}
variable "security_port13"{}
variable "security_port14"{}
variable "controlplane_ami_id"{}
variable "worker_ami_id"{}
variable "aws_key_name"{}

# Create a VPC

resource "aws_vpc" "eng110-project-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "eng110-project-vpc"
  }
}

# Create a Network ACL

resource "aws_network_acl" "eng110-project-acl" {
  vpc_id = aws_vpc.eng110-project-vpc.id
  subnet_ids = ["${aws_subnet.eng110-project-subnet.id}"]
  
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.nacl_cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.nacl_cidr_block
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "eng110-project-nacl"
  }
}

# Launch a subnet

resource "aws_subnet" "eng110-project-subnet" {
  vpc_id            = aws_vpc.eng110-project-vpc.id
  cidr_block        = var.subnet_cidr
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zone_aws

  tags = {
    Name = "eng110-project-subnet"
  }
}

# Internet gateway

resource "aws_internet_gateway" "eng110-project-igw" {
    vpc_id = "${aws_vpc.eng110-project-vpc.id}"
    tags = {
        Name = "eng110-project-igw"
    }
}

# Route table

resource "aws_route_table" "eng110-project-public-crt" {
    vpc_id = "${aws_vpc.eng110-project-vpc.id}"
    
    route {
        # Associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        # CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.eng110-project-igw.id}" 
    }
    
    tags = {
        Name = "eng110-project-public-crt"
    }
}

# Associate CRT and Subnet

resource "aws_route_table_association" "eng110-project-crta-public-subnet"{
    subnet_id = "${aws_subnet.eng110-project-subnet.id}"
    route_table_id = "${aws_route_table.eng110-project-public-crt.id}"
}

# Security group for Kubernetes

resource "aws_security_group" "eng110-project-sg"  {
  name = "eng110-project-sg-tf"
  description = "eng110-project-sg-tf"
  vpc_id = aws_vpc.eng110-project-vpc.id

  ingress {
    from_port       = var.security_port1
    to_port         = var.security_port1
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

  ingress {
    from_port       = var.security_port2
    to_port         = var.security_port2
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

ingress {
    from_port       = var.security_port3
    to_port         = var.security_port4
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

ingress {
    from_port       = var.security_port5
    to_port         = var.security_port5
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

ingress {
    from_port       = var.security_port6
    to_port         = var.security_port6
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

ingress {
    from_port       = var.security_port7
    to_port         = var.security_port7
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

ingress {
    from_port       = var.security_port8
    to_port         = var.security_port9
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

ingress {
    from_port       = var.security_port10
    to_port         = var.security_port10
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

ingress {
    from_port       = var.security_port11
    to_port         = var.security_port11
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

ingress {
    from_port       = var.security_port12
    to_port         = var.security_port13
    protocol        = "udp"
    cidr_blocks     = [var.security_cidr]
  }

ingress {
    from_port       = var.security_port14
    to_port         = var.security_port14
    protocol        = "tcp"
    cidr_blocks     = [var.security_cidr]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" 
    cidr_blocks     = [var.security_cidr]
  }

  tags = {
    Name = "eng110-project-sg-tf"
  }
}

# Launch the Kubernetes Controlplane

resource "aws_instance" "eng110-project-kubernetes-controlplane" {
  ami = var.controlplane_ami_id
  # We need two CPUs, so t2.medium will be chosen
  instance_type = "t2.medium"
  key_name = var.aws_key_name
  subnet_id = "${aws_subnet.eng110-project-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.eng110-project-sg.id}"]
  associate_public_ip_address = true
  tags = {Name = "eng110-project-kubernetes-controlplane"}
}

# Launch one worker node

resource "aws_instance" "eng110-project-kubernetes-worker1" {
  ami = var.worker_ami_id
  # Workers only need one CPU
  instance_type = "t2.micro"
  key_name = var.aws_key_name
  subnet_id = "${aws_subnet.eng110-project-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.eng110-project-sg.id}"]
  associate_public_ip_address = true
  tags = {Name = "eng110-project-kubernetes-worker1"}
}

# Launch a second worker node

resource "aws_instance" "eng110-project-kubernetes-worker2" {
  ami = var.worker_ami_id
  # Workers only need one CPU
  instance_type = "t2.micro"
  key_name = var.aws_key_name
  subnet_id = "${aws_subnet.eng110-project-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.eng110-project-sg.id}"]
  associate_public_ip_address = true
  tags = {Name = "eng110-project-kubernetes-worker2"}
}