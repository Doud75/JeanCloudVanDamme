resource "aws_vpc" "france" {
  provider = aws.france
  cidr_block = var.vpc_france_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc-france" }
}

resource "aws_subnet" "france_az1" {
  provider = aws.france
  vpc_id = aws_vpc.france.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true 
  availability_zone = var.availability_zone_france
  tags = { Name = "${var.project_name}-subnet-france-az1" }
}

resource "aws_subnet" "france_az2" {
  provider = aws.france
  vpc_id = aws_vpc.france.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone_france_2
  tags = { Name = "${var.project_name}-subnet-france-az2" }
}

resource "aws_subnet" "france_private_az1" {
  provider = aws.france
  vpc_id = aws_vpc.france.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false  # Private Subnet
  availability_zone = var.availability_zone_france
  tags = { Name = "${var.project_name}-private-subnet-france-az1" }
}

resource "aws_subnet" "france_private_az2" {
  provider = aws.france
  vpc_id = aws_vpc.france.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = false  # Private Subnet
  availability_zone = var.availability_zone_france_2
  tags = { Name = "${var.project_name}-private-subnet-france-az2" }
}

resource "aws_internet_gateway" "france" {
  provider = aws.france
  vpc_id = aws_vpc.france.id
  tags = { Name = "${var.project_name}-igw-france" }
}

resource "aws_route_table" "france_public" {
  provider = aws.france
  vpc_id = aws_vpc.france.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.france.id
  }
  tags = { Name = "${var.project_name}-route-public" }
}

resource "aws_route_table_association" "france_az1" {
  provider = aws.france
  subnet_id = aws_subnet.france_az1.id
  route_table_id = aws_route_table.france_public.id
}

resource "aws_route_table_association" "france_az2" {
  provider = aws.france
  subnet_id = aws_subnet.france_az2.id
  route_table_id = aws_route_table.france_public.id
}

# 🔹 NAT Gateway (For Private Subnets to Reach Internet)
resource "aws_eip" "nat" {
  provider = aws.france
  domain = "vpc"
}

resource "aws_nat_gateway" "france" {
  provider = aws.france
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.france_az1.id  # Public Subnet for NAT
  tags = { Name = "${var.project_name}-nat-gateway-france" }
}

resource "aws_route_table" "france_private" {
  provider = aws.france
  vpc_id = aws_vpc.france.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.france.id  # NAT Gateway
  }
  tags = { Name = "${var.project_name}-private-route" }
}

resource "aws_route_table_association" "private_az1" {
  provider = aws.france
  subnet_id = aws_subnet.france_private_az1.id
  route_table_id = aws_route_table.france_private.id
}

resource "aws_route_table_association" "private_az2" {
  provider = aws.france
  subnet_id = aws_subnet.france_private_az2.id
  route_table_id = aws_route_table.france_private.id
}

resource "aws_vpc" "germany" {
  provider             = aws.germany
  cidr_block           = var.vpc_germany_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc-germany"
  }
}

resource "aws_subnet" "germany_az1" {
  provider                = aws.germany
  vpc_id                  = aws_vpc.germany.id
  cidr_block              = var.subnet_germany_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_germany
  tags = {
    Name = "${var.project_name}-subnet-germany_az1"
  }
}
resource "aws_subnet" "germany_az2" {
  provider                = aws.germany
  vpc_id                  = aws_vpc.germany.id 
  cidr_block              = "10.1.2.0/24"  
  availability_zone       = "eu-central-1b"  
  
  tags = {
    Name = "${var.project_name}-subnet-germany_az2" 
  }
}

resource "aws_internet_gateway" "germany" {
  provider = aws.germany
  vpc_id   = aws_vpc.germany.id
  tags = {
    Name = "${var.project_name}-igw-germany"
  }
}

resource "aws_route_table" "germany_public" {
  provider = aws.germany
  vpc_id   = aws_vpc.germany.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.germany.id
  }
  tags = {
    Name = "${var.project_name}-route-public-germany"
  }
}

resource "aws_route_table_association" "germany" {
  provider      = aws.germany
  subnet_id     = aws_subnet.germany_az1.id
  route_table_id = aws_route_table.germany_public.id
}
