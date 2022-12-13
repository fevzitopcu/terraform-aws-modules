resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true



  tags = {
    Name = "${var.project}-${terraform.workspace}-vpc"
  }
}
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.project}-IGW"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc = true
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
    ignore_changes        = all
  }
  tags = {
    Name = "${var.project}-nat-eip"

  }
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public-subnets.*.id, 0)


  tags = {
    Name = "${var.project}-nat"
  }
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name          = "service.consul"
  domain_name_servers  = ["127.0.0.1", "10.0.0.2"]
  ntp_servers          = ["127.0.0.1"]
  netbios_name_servers = ["127.0.0.1"]
  netbios_node_type    = 2

  tags = {
    Name = "${var.project}-dhcp_options"
  }
}

resource "aws_vpc_dhcp_options_association" "dhcp-options-association" {
  vpc_id          = aws_vpc.main-vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.id
}
resource "aws_subnet" "public-subnets" {
  vpc_id                  = aws_vpc.main-vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-${element(var.availability_zones, count.index)}-public-subnet"
  }
}

resource "aws_subnet" "private-subnets" {
  vpc_id                  = aws_vpc.main-vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-${element(var.availability_zones, count.index)}-private-subnet"

  }
}

# default route table

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.main-vpc.default_route_table_id

  tags = {
    Name = "${var.project}-default-route-table"

  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.project}-public-route-table"

  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public-subnets)
  subnet_id      = element("${aws_subnet.public-subnets.*.id}", count.index)
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route" "public-route" {
  count                  = length(aws_subnet.public-subnets)
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW.id

  timeouts {
    create = "5m"
  }

}
# ---------------------private route table-----------------------------------------
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.project}-private-route-table"

  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private-subnets)
  subnet_id      = element("${aws_subnet.private-subnets.*.id}", count.index)
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route" "private-route" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id

  timeouts {
    create = "5m"
  }

}

