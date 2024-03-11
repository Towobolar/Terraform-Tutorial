/**********************
*        VPC         *
**********************/

resource "aws_vpc" "major-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    name = "project vpc"
  }
}

/*******************************
*        Public subnet         *
********************************/

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.major-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "project public subnet"
  }
}

/*******************************
*        Private subnet         *
********************************/

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.major-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "project private subnet"
  }
}

/*******************************
*        internet gateway         *
********************************/

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.major-vpc.id

  tags = {
    Name = "internet gw"
  }
}

/*******************************
*        route table         *
********************************/

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.major-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "internet public route"
  }
}

/***********************************
*        route association         *
************************************/

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

/*******************************
*        security group        *
********************************/

resource "aws_security_group" "major-vpc-sg" {
  vpc_id = aws_vpc.major-vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
    cidr_blocks = ["85.255.237.87/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*******************************
*        ec2 instance         *
********************************/
resource "aws_instance" "main-instance" {
  ami           = ami-0f403e3180720dd7e
  instance_type = "t2.micro"

  tags = {
    Name = "ec2"
  }
}
