# VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 퍼블릭 서브넷 생성 (ALB 및 EC2용)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# 프라이빗 RDS 서브넷 생성
resource "aws_subnet" "private_rds" {
  count             = length(var.private_rds_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_rds_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-rds-subnet-${count.index + 1}"
  }
}

# 퍼블릭 라우팅 테이블 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# 퍼블릭 서브넷을 퍼블릭 라우팅 테이블에 연결
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 프라이빗 RDS 서브넷을 기본 라우팅 테이블에 연결
resource "aws_route_table_association" "private_rds" {
  count          = length(var.private_rds_subnet_cidrs)
  subnet_id      = aws_subnet.private_rds[count.index].id
  route_table_id = aws_vpc.main.default_route_table_id
}

# 가용 영역 데이터 소스
data "aws_availability_zones" "available" {
  state = "available"
}