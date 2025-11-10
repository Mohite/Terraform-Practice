# ---------------------------
# Create a VPC
# ---------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
 enable_dns_support   = true        # ✅ Required for RDS public endpoint
 enable_dns_hostnames = true        # ✅ Required for RDS public endpoint

  tags = {
    Name = "main-vpc"
  }
}

# ---------------------------
# Create Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# ---------------------------
# Create Public Route Table
# ---------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# ---------------------------
# Create 2 Subnets in different AZs (public)
# ---------------------------
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# ---------------------------
# Associate Subnets with Route Table
# ---------------------------
resource "aws_route_table_association" "assoc1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "assoc2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------------------
# Security Group for RDS
# ---------------------------
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 👈 For testing. Replace with your IP for security.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# ---------------------------
# Create DB Subnet Group (RDS requirement)
# ---------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "rds-subnet-group"
  }
}

# ---------------------------
# Create RDS Instance
# ---------------------------
resource "aws_db_instance" "mysql_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "admin"
  password             = "Admin1234"
  publicly_accessible  = true
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true

  tags = {
    Name = "mysql-rds"
  }
}

# ---------------------------
# Execute SQL file locally after DB creation
# ---------------------------
resource "null_resource" "local_sql_exec" {
  depends_on = [aws_db_instance.mysql_rds]

provisioner "local-exec" {
  interpreter = ["cmd", "/C"]
  command     = "run_mysql.bat ${aws_db_instance.mysql_rds.address}"
}


  triggers = {
    always_run = timestamp()
  }
}
