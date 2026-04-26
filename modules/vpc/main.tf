data "aws_availability_zones" "available" {}

locals {
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i + 10)]
}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    # Required tags for EKS to discover subnets
    # "kubernetes.io/cluster/${var.project_name}-${var.environment}-cluster" = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project_name}-${var.environment}-igw" }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    # "kubernetes.io/cluster/${var.project_name}-${var.environment}-cluster" = "shared"
    # "kubernetes.io/role/elb"                    = "1"  # Required for public ALBs
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name                                        = "${var.project_name}-${var.environment}-private-${count.index + 1}"
    # "kubernetes.io/cluster/${var.project_name}-${var.environment}-cluster" = "shared"
    # "kubernetes.io/role/internal-elb"           = "1"  # Required for internal ALBs
  }
}

# # Elastic IPs for NAT Gateways
# resource "aws_eip" "nat" {
#   count  = length(local.azs)
#   domain = "vpc"
#   tags   = { Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}" }
# }

# Single Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.project_name}-${var.environment}-nat-eip" }
}

# # NAT Gateways (one per AZ for HA)
# resource "aws_nat_gateway" "this" {
#   count         = length(local.azs)
#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id     = aws_subnet.public[count.index].id
#   tags          = { Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}" }
#   depends_on    = [aws_internet_gateway.this]
# }

# Single NAT Gateway for cost optimization
resource "aws_nat_gateway" "this" {
  # count         = 1
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id 
  tags = { 
    Name = "${var.project_name}-${var.environment}-nat-single" 
  } 
  depends_on = [aws_internet_gateway.this]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.project_name}-${var.environment}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# # Private Route Tables (one per AZ)
# resource "aws_route_table" "private" {
#   count  = length(local.azs)
#   vpc_id = aws_vpc.this.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.this[count.index].id
#   }
#   tags = { Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}" }
# }

# Single Private Route Table for all AZs
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = { Name = "${var.project_name}-${var.environment}-private-rt" }
}

# resource "aws_route_table_association" "private" {
#   count          = length(local.azs)
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private[count.index].id
# }

# Single Private Route Table Assosiation for all AZs
resource "aws_route_table_association" "private" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

// Load balancer Security Group
resource "aws_security_group" "lb_sg" {
  name        = "${var.project_name}-${var.environment}-lb-sg"
  description = "Security group for the Load balance"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.project_name}-${var.environment}-lb-sg" 
    }
}

//Create the Laod balancer to be attached
resource "aws_lb" "vprofileLB" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets = [for s in aws_subnet.public : s.id]
  tags = { 
    Name = "${var.project_name}-${var.environment}-alb" 
    }
}
