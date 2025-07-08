data "aws_region" "current" {}

# VPC  
resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  tags                 = var.tags
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Private Subnet  
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = merge(var.tags, {
    Name = "Private Subnet - 1"
  })
}

# Private Route Table no egress
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.app_vpc.id
  tags = merge(var.tags, {
    Name = "Private Route Table"
  })
}

resource "aws_route_table_association" "private_subnet_asso" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "endpoint_sg" {
  name        = "prv-mongodb-sg"
  vpc_id      = aws_vpc.app_vpc.id
  description = "SG for MongoDB Atlas"

  # This allows all traffic from the VPC  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.app_vpc.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.app_vpc.cidr_block]
  }
  tags = merge(var.tags, {
    Name = "MongoDB Atlas Security Group"
  })
}

resource "aws_vpc_endpoint" "atlas" {
  vpc_id             = aws_vpc.app_vpc.id
  vpc_endpoint_type  = "Interface"
  service_name       = var.atlas_private_endpoint_service_name
  subnet_ids         = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]


  private_dns_enabled = false

  tags = merge(var.tags, {
    Name = "MongoDB Atlas endpoint"
  })
}

resource "mongodbatlas_privatelink_endpoint_service" "private_endpoint_service_connection" {
  project_id          = var.atlas_project_id
  private_link_id     = var.atlas_private_endpoint_link_id
  endpoint_service_id = aws_vpc_endpoint.atlas.id
  provider_name       = "AWS"
}


resource "aws_vpc_endpoint" "sts" {
  vpc_id              = aws_vpc.app_vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  tags = merge(var.tags, {
    Name = "sts-endpoint"
  })
}
