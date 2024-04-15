# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.10.0.0/16" # Customize the CIDR block as needed
}

# Create a subnet within the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.10.1.0/24" # Customize the CIDR block as needed
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a security group
resource "aws_security_group" "demosg" {
  name        = "my_security_group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust the source IP range as needed
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust the source IP range as needed
  }
  
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust the source IP range as needed
  }
}

resource "aws_instance" "demo" {
  ami           = "ami-080e1f13689e07408" # Replace with the desired AMI ID
  instance_type = "t2.micro"
  key_name      = "demo-1"
  vpc_security_group_ids = [aws_security_group.demosg.id]   
  subnet_id     = aws_subnet.my_subnet.id 
  associate_public_ip_address = true    
  root_block_device {
    volume_size           = 8             
    volume_type           = "gp2"         
    delete_on_termination = true          
  }        
  tags = {
    Name = "demo-devops"
  }
}
