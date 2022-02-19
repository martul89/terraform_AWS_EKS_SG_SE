resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-VPC"
    Environment = "${var.prefix}-terraform"
  }
}

 resource "aws_subnet" "management-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.management_subnet_cidr
  availability_zone       = var.aws_az2
  tags = {
    Name = "${var.prefix}-mgmt-subnet"
    Environment = "${var.prefix}-terraform"
  }
} 

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.aws_az1
  map_public_ip_on_launch = true

  tags = {
    Name = "Web Public Subnet"
    Environment = "${var.prefix}-terraform"
    "kubernetes.io/role/elb" = "1"
    # !!!! "kubernetes.io/cluster/${var.cluster-name}-${random_id.random-string.dec}" = "shared"
  }
}

# Define the private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.aws_az1
  map_public_ip_on_launch = false

  tags = {
    Name = "Web Private Subnet"
    Environment = "${var.prefix}-terraform"
    "kubernetes.io/role/internal-elb" = "1"
   # !!!! "kubernetes.io/cluster/${var.cluster-name}-${random_id.random-string.dec}" = "shared"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-IGW"
    Environment = "${var.prefix}-terraform"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = aws_subnet.public-subnet.id
  depends_on    = [aws_internet_gateway.gw]
  tags = {
    Name        = "${var.prefix}-NAT"
    Environment = "${var.prefix}-terraform"
  }
}


resource "aws_route_table" "web-public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.prefix}-Public-Routing-Table"
    Environment = "${var.prefix}-terraform"
  }
}

resource "aws_route_table" "web-private-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.prefix}-Private-Routing-Table"
    Environment = "${var.prefix}-terraform"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.web-public-rt.id
}

resource "aws_route_table_association" "web-private-rt" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.web-private-rt.id
}

resource "aws_security_group" "public" {
  name        = "${var.prefix}-public-security-group"
  description = "Allow traffic from internet"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-public-security-group"
    Environment = "${var.prefix}-terraform"
  }
}

resource "aws_security_group" "private" {
  name        = "${var.prefix}-private-security-group"
  description = "Allow traffic from public subnet"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-private-security-group"
    Environment = "${var.prefix}-terraform"
  }
}
