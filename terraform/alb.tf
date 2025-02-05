resource "aws_lb" "france" {
  provider = aws.france
  name = "${var.project_name}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = [aws_subnet.france_az1.id, aws_subnet.france_az2.id]
}

resource "aws_lb_target_group" "france" {
  provider    = aws.france
  name        = "${var.project_name}-tg"
  port        = var.backend_container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.france.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "http" {
  provider           = aws.france
  load_balancer_arn = aws_lb.france.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.france.arn
  }
}

resource "aws_lb" "germany" {
  provider = aws.germany
  name               = "${var.project_name}-alb-germany"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_germany.id]
  subnets            = [aws_subnet.germany_az1.id, aws_subnet.germany_az2.id] 
}



resource "aws_lb_listener" "germany_http" {
  provider = aws.germany
  load_balancer_arn = aws_lb.germany.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.germany.arn
  }
}

resource "aws_lb_target_group" "germany" {
  provider = aws.germany  
  name        = "${var.project_name}-tg-germany"
  port        = var.backend_container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.germany.id
  target_type = "ip"

  # Même configuration de health check
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-499"
  }
}