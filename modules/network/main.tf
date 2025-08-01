resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.azs, count.index)
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

# Security Groups for each tier (simplified)
resource "aws_security_group" "web" {
  vpc_id = aws_vpc.this.id
ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "web-sg"
  }
}

resource "aws_security_group" "web_alb" {
  vpc_id = aws_vpc.this.id
ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "webalb-sg"
  }
}

resource "aws_security_group" "app" {
  vpc_id = aws_vpc.this.id
ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }

}

resource "aws_security_group" "db" {
  vpc_id = aws_vpc.this.id
ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }


}

output "vpc_id"             { value = aws_vpc.this.id }
output "public_subnets"     { value = aws_subnet.public[*].id }
output "private_subnets"    { value = aws_subnet.private[*].id }
output "web_sg_id"          { value = aws_security_group.web.id }
output "web_alb_sg_id"      { value = aws_security_group.web_alb.id }
output "app_sg_id"          { value = aws_security_group.app.id }
output "db_sg_id"           { value = aws_security_group.db.id }
output "private_db_subnets" { value = aws_subnet.private[*].id }
