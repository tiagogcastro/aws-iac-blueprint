# VPC, internet gateway, public and private subnets, and route tables.

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.resource_tags, {
    Name = "${var.project_name}-${var.deployment_environment}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.resource_tags, {
    Name = "${var.project_name}-${var.deployment_environment}-igw"
  })
}

resource "aws_subnet" "public" {
  count = length(var.vpc_public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.vpc_public_subnet_cidrs[count.index]
  availability_zone       = var.vpc_availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.resource_tags, {
    Name = "${var.project_name}-${var.deployment_environment}-public-subnet-${count.index + 1}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  count = length(var.vpc_private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.vpc_private_subnet_cidrs[count.index]
  availability_zone = var.vpc_availability_zones[count.index]

  tags = merge(var.resource_tags, {
    Name = "${var.project_name}-${var.deployment_environment}-private-subnet-${count.index + 1}"
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.resource_tags, {
    Name = "${var.project_name}-${var.deployment_environment}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.resource_tags, {
    Name = "${var.project_name}-${var.deployment_environment}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
