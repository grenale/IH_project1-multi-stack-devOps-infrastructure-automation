provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "gan_project1_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true


    tags = {
        Name = "gan_project1_vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.gan_project1_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-west-2a"
    map_public_ip_on_launch = true

    tags = {
      Name = "gan_project1_public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.gan_project1_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-west-2a"

    tags = {
      Name = "gan_project1_private_subnet"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gan_project1_vpc.id

  tags = {
    Name = "gan_project1_igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.gan_project1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

tags = {
    Name = "gan_project1-public_route_table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.gan_project1_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

    tags = {
      Name = "gan_frontend_sg"
    }
}

resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.gan_project1_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gan_backend_sg"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.gan_project1_vpc.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database_sg"
  }
}

resource "aws_instance" "frontend" {
  ami = "ami-05c172c7f0d3aed00"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.frontend_sg.id]
  key_name = "gan_kp"

  tags = {
    Name = "gan_frontend_instance"
  }
}

resource "aws_instance" "backend" {
  ami = "ami-05c172c7f0d3aed00"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.backend_sg.id]
  key_name = "gan_kp"

  tags = {
    Name = "gan_backend_instance"
  }
}

resource "aws_instance" "database" {
  ami           = "ami-05c172c7f0d3aed00"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.db_sg.id]
  key_name = "gan_kp"

  tags = {
    Name = "gan_database_instance"
  }
}

output "private_ip" {
  value = aws_instance.backend.private_ip
}

output "public_ip" {
  value = aws_instance.frontend.public_ip
}