# Creates RDS Instance 
resource "aws_db_instance" "mysql" {
  identifier             = "roboshop-mysql-${var.ENV}"
  allocated_storage      = var.MYSQL_STORAGE
  engine                 = "mysql"
  engine_version         = var.MYSQL_ENGINE_VERSION
  instance_class         = var.MYSQL_INSTANCE_CLASS
  db_name                = "dummy"
  username               = "admin1"
  password               = "RoboShop1"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true                 # True only for non-prod workloads
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
}

# Creates Parameter Group 
resource "aws_db_parameter_group" "mysql" {
  name   = "roboshop-mysql-${var.ENV}"
  family = "mysql5.7"
}

# Creates DB Subnet Group
resource "aws_db_subnet_group" "mysql" {
  name       = "roboshop-mysql-${var.ENV}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS

  tags = {
    Name = "roboshop-subnet-group-mysql-${var.ENV}"
  }
}

# Creates Security Group for MySQL
resource "aws_security_group" "allow_mysql" {
  name        = "roboshop-mysql-${var.ENV}"
  description = "roboshop-mysql-${var.ENV}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description      = "Allow MySQL Connection From Default VPC"
    from_port        = var.MYSQL_PORT_NUMBER
    to_port          = var.MYSQL_PORT_NUMBER
    protocol         = "tcp"
    cidr_blocks      = [data.terraform_remote_state.vpc.outputs.DEFAULT_VPC_CIDR]
  }

  ingress {
    description      = "Allow MySQL Connection From Private VPC"
    from_port        = var.MYSQL_PORT_NUMBER
    to_port          = var.MYSQL_PORT_NUMBER
    protocol         = "tcp"
    cidr_blocks      = [data.terraform_remote_state.vpc.outputs.VPC_CIDR]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "roboshop-mysql-sg-${var.ENV}"
  }
}
