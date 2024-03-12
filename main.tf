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
  vpc_id            = aws_vpc.major-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "project public subnet"
  }
}

/*******************************
*        Private subnet         *
********************************/

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.major-vpc.id
  cidr_block        = "10.0.2.0/24"
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

resource "aws_security_group" "web-sg" {
  name = "web-sg"
  description = "allow inbound ssh and https traffic"
  vpc_id = aws_vpc.major-vpc.id

  ingress {
    protocol    = "http"
    self        = true
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["85.255.237.87/32"]
  }

   ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 22
    to_port     = 22
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
resource "aws_instance" "web-instance" {
  ami                    = "ami-09885f3ec1667cbfc"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = aws_key_pair.brainiac-key.id

  tags = {
    Name = "web ec2"
  }
}


/*******************************
*        Key pair         *
********************************/

resource "aws_key_pair" "brainiac-key" {
  key_name   = "test-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqb6C7CS4aZdjn97tOf812QEQC7R5a6/Y1vwaXPWOOmFnkK/1UucVbLJe88YBr0vlrAHnv7nsg5b9a7Lmj/Y9Rbo2q/g6bUiHoXJEHQ5/hOe7eYVlt0Pf1dtcK7Ti22dsoOjgZ4QWXcTWB7wGc1cnmUp96AnSc12+qLJ30moeo0be62rchptPvpWlAo4Xb0jcK6Wk8pWqMO1Nem4pkfudVQNe83inJc6yjelUBdGkRVRUDeWjFGxQtFygTn5wY0ExSxcpEOCSBu75HrHb8FwNBPurn/9Umy4oaGkv8oryaEoLGv60yf+Iyge3SuYwiHlmWs9Dof877fD6tMM8Zgu6n5ujm3Oa4mlFSx2IKmQUnWGBIv+4Fuhcvb96jvxut1Wg1xb5gOmO355ce1nkboAYBLghtHi5ZN66kp7AMwE/LAO/RPVZLibZtLkf8Csu+xPpFrbAktprlAmtUUEMaaWNwemWnsBUgH5SmtgOFGUlPgb58H7H9S/Xi+bNt2THMO9k= abbey@TOWOBOLA"
}

  