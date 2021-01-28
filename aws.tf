provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = "aws-creds"
}

data "aws_vpc" "default_network" {
  default = true
}

data "aws_subnet" "subnet_zone_a" {
  vpc_id            = data.aws_vpc.default_network.id
  default_for_az    = true
  availability_zone = "us-east-2a"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "allow http traffic"
  vpc_id      = data.aws_vpc.default_network.id

  ingress {
    description = "http traffic from the internet"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    provisioner = "terraform"
    environment = "integration"
    project     = "sandbox"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "allow ssh traffic"
  vpc_id      = data.aws_vpc.default_network.id

  ingress {
    description = "ssh traffic from me"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["24.242.23.224/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    provisioner = "terraform"
    environment = "integration"
    project     = "sandbox"
  }
}

resource "aws_network_interface" "appserver_net_inter" {
  subnet_id       = data.aws_subnet.subnet_zone_a.id
  description     = "network interface for appserver aws"
  security_groups = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]

  tags = {
    provisioner = "terraform"
    environment = "integration"
    project     = "sandbox"
  }
}

resource "aws_instance" "appserver_aws" {
  tags = {
    Name        = "appserver"
    provisioner = "terraform"
    environment = "integration"
    project     = "sandbox"
  }

  instance_type     = "t2.micro"
  availability_zone = "us-east-2a"

  ami = "ami-0a91cd140a1fc148a"

  root_block_device {
    delete_on_termination = true
    tags = {
      provisioner = "terraform"
      environment = "integration"
      project     = "sandbox"
    }
    volume_size = 20
    volume_type = "gp2"
  }

  network_interface {
    delete_on_termination = true
    device_index          = 0
    network_interface_id  = aws_network_interface.appserver_net_inter.id
  }

}