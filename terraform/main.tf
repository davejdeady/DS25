
# 1) Create a Security Group to be attached with the Application Load Balancer (ALB)
# (ingress and egress from any ip's on port 80)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.access_cidr_blocks
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.access_cidr_blocks
  }
}

# 2) Create a Security Group to be attached with the EC2 instances.
# (ingress only allowed from Load Balancer Security Group on port 80 and no egress rules mentioned. Security group rules are stateful.)
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
}

# 3) Create a Target Group for the Load Balancer. This will use port 80 for the communication with the target instances.
# This also send a periodic health check calls on port 80 to the target instances which helps ALB know the status of instances. If any target is unhealthy, ALB avoids that one and send traffic to a healthy target.
resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags     = local.tags
}

# 4) Create ALB (Application Load Balancer) in the public subnets and attach the Security Group created above for the ALB.
resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids
  tags               = local.tags
}


# 5) Create a load balancer listener to check for connection requests using the port and protocol we configured. 
# We register the target groups here and the listener will forward the traffic as per the rules we configured here.
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
  tags = local.tags
}


# 6) Create a launch template to create the web EC2 instances using the defined image (ami). This ami has preinstalled nginx web server and the html web page we need to host.
# User data script to read the instance ID from metadata info and replaces this instance ID in the web page.
resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.project_name}-web-lt"
  image_id      = var.instance_ami
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data            = filebase64("${path.module}/bootstrap.sh")

  tag_specifications {
    resource_type = "instance"
    tags = local.tags
  }
}

# 7) Create an auto-scaling group which takes care of the deployment of required EC2's in associated subnets.
# Here we attach the launch template created above, and define the number of EC2 instances we need.
# The ASG does a periodical EC2 status health check. If the instance status check fails, it creates a new instance and registers to the target group we mention here (This health check has no relation with the target group http health checks mentioned above for the web traffic routing, but we can also enable this in ASG).
resource "aws_autoscaling_group" "web_asg" {
  name                      = "${var.project_name}-web-asg"
  max_size                  = var.capacity["max_size"]
  min_size                  = var.capacity["min_size"]
  desired_capacity          = var.capacity["desired_capacity"]
  vpc_zone_identifier       = var.private_subnet_ids
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
  target_group_arns         = [aws_lb_target_group.tg.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
}
