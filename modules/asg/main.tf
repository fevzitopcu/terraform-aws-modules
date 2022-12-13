
data "aws_vpc" "main-vpc" {
  filter {
    name   = "tag:Name"
    values = ["project-default-vpc"]
  }
}

data "aws_subnets" "public" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main-vpc.id]
  }

  tags = {
    Name = "*public*"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_launch_configuration" "asg-launch-config" {
  name = "${terraform.workspace}-asg-launch-config"
  image_id      = local.workspace["ami"]
  instance_type = local.workspace["instance_type"]
  
  user_data     = <<EOF
      #!/bin/bash
      yum update -y
      yum -y remove httpd
      yum -y remove httpd-tools
      yum install -y httpd24 php72 mysql57-server php72-mysqlnd
      service httpd start
      chkconfig httpd on

      usermod -a -G apache ec2-user
      chown -R ec2-user:apache /var/www
      chmod 2775 /var/www
      find /var/www -type d -exec chmod 2775 {} \;
      find /var/www -type f -exec chmod 0664 {} \;
      cd /var/www/html
      curl http://169.254.169.254/latest/meta-data/instance-id -o index.html
      curl https://raw.githubusercontent.com/hashicorp/learn-terramino/master/index.php -O
  EOF

  security_groups = [aws_security_group.sg-instance.id]

  lifecycle {
    create_before_destroy = true
  }


}

resource "aws_autoscaling_group" "my-asg" {
  name                 = "${terraform.workspace}-asg"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.asg-launch-config.id
  vpc_zone_identifier  = data.aws_subnets.public.ids

  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-asg-instance"
    propagate_at_launch = true
  }

}

resource "aws_lb" "load-balancer" {
  name               = "${terraform.workspace}-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load-balancer-sg.id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "lb_listener" {

  load_balancer_arn = aws_lb.load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-gr.arn
  }
}

resource "aws_lb_target_group" "target-gr" {
  name     = "${terraform.workspace}-target-gr"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main-vpc.id
}

resource "aws_autoscaling_attachment" "asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.my-asg.id
  lb_target_group_arn    = aws_lb_target_group.target-gr.arn
}


resource "aws_security_group" "sg-instance" {
  name = "${terraform.workspace}-asg-sg-instance-sg"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load-balancer-sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load-balancer-sg.id]
  }

  vpc_id = data.aws_vpc.main-vpc.id
}

resource "aws_security_group" "load-balancer-sg" {
  name = "${terraform.workspace}-asg-load-balancer-sgr"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = data.aws_vpc.main-vpc.id
}
