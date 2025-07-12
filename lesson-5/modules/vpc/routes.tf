# Create a routing table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id                              # Bind the table to our VPC

  tags = {
    Name = "${var.vpc_name}-public-rt"                  # Tag for route table
  }
}

# Add a route to access the Internet via the Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id    # Route table ID
  destination_cidr_block = "0.0.0.0/0"                  # All IP addresses
  gateway_id             = aws_internet_gateway.igw.id  # Specify Internet Gateway as output
}

# Bind the route table to public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)           # Bind each subnet
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
