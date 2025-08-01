resource "aws_launch_template" "app" {
  name_prefix   = "app-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = var.sg_ids
  user_data     = base64encode(var.user_data)
}

resource "aws_autoscaling_group" "app" {
  desired_capacity     = var.desired_capacity
  min_size             = var.min_size
  max_size             = var.max_size
  vpc_zone_identifier  = var.subnets
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "app"
    propagate_at_launch = true
  }
}
