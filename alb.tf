# ALB 생성
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ALB 타겟 그룹 생성
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# EC2 인스턴스 1을 타겟 그룹에 연결
resource "aws_lb_target_group_attachment" "web_server_1" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web_server_1.id
  port             = 80
}

# EC2 인스턴스 2를 타겟 그룹에 연결
resource "aws_lb_target_group_attachment" "web_server_2" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web_server_2.id
  port             = 80
}

# ALB HTTP 리스너 생성
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}