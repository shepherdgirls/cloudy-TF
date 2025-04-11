# Amazon Linux 2 AMI 검색
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# EC2 인스턴스 1
resource "aws_instance" "web_server_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name               = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
    tags = {
      Name = "${var.project_name}-web-server-1-volume"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Web Server 1</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-web-server-1"
  }
}

# EC2 인스턴스 2
resource "aws_instance" "web_server_2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name               = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
    tags = {
      Name = "${var.project_name}-web-server-2-volume"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Web Server 2</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-web-server-2"
  }
}