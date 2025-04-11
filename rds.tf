# RDS 서브넷 그룹 생성
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_rds : subnet.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS 마리아DB 인스턴스 생성
resource "aws_db_instance" "main" {
  identifier           = "${var.project_name}-db"
  engine               = "mariadb"
  engine_version       = "10.5"
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  max_allocated_storage = 100
  
  db_name              = "appdb"
  username             = "admin"
  password             = var.db_password
  port                 = 3306
  
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  multi_az             = false
  publicly_accessible  = false
  skip_final_snapshot  = true
  
  backup_retention_period = 7
  backup_window           = "03:00-05:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  
  tags = {
    Name = "${var.project_name}-db"
  }
}