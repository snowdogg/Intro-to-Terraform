
provider "aws" { 
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"	
  tags = {
    Name = "my amazing vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.default.id
}

resource "aws_network_acl" "allowall" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol = "-1" #all protocols (tcp/udp etc)
    rule_no = 100 #where it is in the stack
    action = "allow" #allows all 
    cidr_block = "0.0.0.0/0"
    from_port = 0 #from all port ranges
    to_port = 0 #to all port ranges

  }
  ingress {
    from_port = 0 #from all port ranges 
    to_port = 0 #to all port rangers
    protocol = "-1"
    action = "allow" #allows all
    rule_no = 200 #where it is in the stack
    cidr_block = "0.0.0.0/0" #
  } 
}

resource "aws_security_group" "allowall"{
  name = "Andreas amazing security group made with terraform"
  description = "allows all ssh traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_eip" "webserver" {
  instance = aws_instance.webserver.id
  vpc = true
  depends_on = [aws_internet_gateway.main]
  
}

resource "aws_key_pair" "default" {
  key_name = "fantastic_key"
  public_key = "INSERT PUBLIC KEY STRING HERE"
}

# this block describes an ami
data "aws_ami" "ubuntu" { 
  most_recent = true # of all the results filtered, we shall choose the latest version
  
  filter {
    name = "name"  # field we want to filter by (filter by name)
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"] # the value of the name we want to filter for
  }
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical (creater and maintainers of ubuntu... this tells them to only pull from official ubunutu hub
}
  
resource "aws_instance" "webserver" {
  ami = data.aws_ami.ubuntu.id # the image we described in data.aws.ami_ubunutu.id
  availability_zone = "us-west-2a"
  instance_type = "t2.micro"
  key_name = aws_key_pair.default.key_name
  vpc_security_group_ids = [aws_security_group.allowall.id]
  subnet_id = aws_subnet.main.id
}

output "public_ip"{
  value = aws_eip.webserver.public_ip
}

