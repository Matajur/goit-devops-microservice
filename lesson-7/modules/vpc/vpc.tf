# Create the main VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block             # CIDR block for our VPC (e.g. 10.0.0.0/16)
  enable_dns_support   = true                 # Enables DNS support in VPC
  enable_dns_hostnames = true                 # Enables the ability to use DNS names for resources in a VPC

  tags = {
    Name = "${var.vpc_name}-vpc"              # Add a tag that includes the VPC name
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)              # Create multiple subnets, the number is determined by the length of the public_subnets list
  vpc_id            = aws_vpc.main.id                         # Bind each subnet to the VPC created earlier
  cidr_block        = var.public_subnets[count.index]         # CIDR block for a specific subnet from the public_subnets list
  availability_zone = var.availability_zones[count.index]     # Define availability zones for each subnet
  map_public_ip_on_launch = true                              # Automatically assigns public IP addresses to instances in a subnet

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}" # Subnet numbering tag
    # count.index is the index of the "count" loop, which starts at 0.
    # ${count.index + 1} adds +1 to the index to get human notation (1, 2, 3 instead of 0, 1, 2).
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)             # Create several private subnets, the number corresponds to the length of the private_subnets list
  vpc_id            = aws_vpc.main.id                         # Bind each private subnet to a VPC
  cidr_block        = var.private_subnets[count.index]        # CIDR block for a specific subnet from the private_subnets list
  availability_zone = var.availability_zones[count.index]     # Define availability zones for subnets

  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
    # ${count.index + 1} is used to make subnet numbering start at 1.
  }
}

# Creating an Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id        # Bind the Internet Gateway to the VPC for Internet access

  tags = {
    Name = "${var.vpc_name}-igw"  # Tag for Internet Gateway identification
  }
}
