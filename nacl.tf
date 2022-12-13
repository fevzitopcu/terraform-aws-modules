#-----------------NACL----------------------

resource "aws_default_network_acl" "default-nacl" {
  default_network_acl_id = aws_vpc.main-vpc.default_network_acl_id

  tags = {
    Name = "${var.project}-default-NACL"
  }

}


resource "aws_network_acl" "public-network-acl" {
  vpc_id = aws_vpc.main-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/18"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.0.0/18"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.0.0.0/18"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.0.0.0/18"
    from_port  = 22
    to_port    = 22
  }


  tags = {
    Name        = "${var.project}-public-NACL"
  }
}

resource "aws_network_acl_association" "public-nacl-association" {

  count          = length(aws_subnet.public-subnets)
  subnet_id      = element("${aws_subnet.public-subnets.*.id}", count.index)
  network_acl_id = aws_network_acl.public-network-acl.id
}

resource "aws_network_acl" "private-network-acl" {
  vpc_id = aws_vpc.main-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/18"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/18"
    from_port  = 0
    to_port    = 0
  }


  tags = {
    Name        = "${var.project}-private-NACL"
  }
}

resource "aws_network_acl_association" "private-nacl-association" {

  count          = length(aws_subnet.private-subnets)
  subnet_id      = element("${aws_subnet.private-subnets.*.id}", count.index)
  network_acl_id = aws_network_acl.private-network-acl.id
}

resource "aws_security_group" "vpc-security-group" {
  vpc_id = aws_vpc.main-vpc.id

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

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name        = "${var.project}-security-group"
  }
}
