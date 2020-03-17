
resource "aws_security_group" "WebServer" {
 name = "WebServer"

 dynamic "ingress" {
      for_each = ["80", "8080", "443", "22"]
      content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      }
                        }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      }
}





resource "aws_s3_bucket" "WebServers" {
  bucket = "ole-epam-project"
  tags = {
    Name        = "ole-epam-project"
  }
  versioning {
    enabled = true
}
}





resource "aws_launch_configuration" "WebServers" {
  name = "WebServers_config"
  image_id = "ami-0e38b48473ea57778"
  instance_type = "t2.micro"
  key_name = "Oleg"
  security_groups = [aws_security_group.WebServer.id]
  iam_instance_profile = aws_iam_instance_profile.IAM_profile.id
  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo service httpd start
sudo yum install php -y
sudo service httpd restart
sudo yum install ruby -y
sudo yum install wget -y
cd /home/ec2-user
wget https://aws-codedeploy-us-east-2.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
sudo service codedeploy-agent status
EOF

  lifecycle {
    create_before_destroy = true
  }
}





resource "aws_autoscaling_group" "WebServers" {
  name                 = "WebServers"
  launch_configuration = aws_launch_configuration.WebServers.name
  min_size             = "2"
  max_size             = "4"
  availability_zones   = ["us-east-2b"]

  tag {
   key                 = "Name"
   value               = "WebServer"
   propagate_at_launch = "true"
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_attachment" "asg_attachment" {
autoscaling_group_name = aws_autoscaling_group.WebServers.id
elb = aws_elb.WebServerLBc.id
alb_target_group_arn = aws_lb_target_group.TargetGroup.arn
}




  resource "aws_autoscaling_policy" "Add_Policy" {
  name = "Add_Policy"
  autoscaling_group_name = aws_autoscaling_group.WebServers.id
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "1"
  cooldown = "60"
  policy_type = "SimpleScaling"
  }
  resource "aws_cloudwatch_metric_alarm" "Add_alarm" {
  alarm_name = "Add_alarm"
  alarm_description = "Add_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "40"
  dimensions = {
  "AutoScalingGroupName" = aws_autoscaling_group.WebServers.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.Add_Policy.arn]
  }



  resource "aws_autoscaling_policy" "Del_Policy" {
  name = "Del_Policy"
  autoscaling_group_name = aws_autoscaling_group.WebServers.id
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "-1"
  cooldown = "60"
  policy_type = "SimpleScaling"
  }
  resource "aws_cloudwatch_metric_alarm" "Del_alarm" {
  alarm_name = "Del_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "10"
  dimensions = {
  "AutoScalingGroupName" = aws_autoscaling_group.WebServers.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.Del_Policy.arn]
  }








resource "aws_codedeploy_app" "WebServer" {
  compute_platform = "Server"
  name             = "WebServer"
}



resource "aws_codedeploy_deployment_group" "WebServer_group" {
  app_name              = aws_codedeploy_app.WebServer.name
  deployment_group_name = "WebServers_group"
  autoscaling_groups = [aws_autoscaling_group.WebServers.id]
  service_role_arn      = aws_iam_role.Codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"


  load_balancer_info {
    target_group_info {
    name = aws_lb_target_group.TargetGroup.name
    }
    }


    deployment_style {
            deployment_option = "WITH_TRAFFIC_CONTROL"
            deployment_type   = "IN_PLACE"

    }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "WebServer"
    }
  }

  auto_rollback_configuration {
    enabled = false
    events  = ["DEPLOYMENT_FAILURE"]
  }
}




resource "aws_iam_instance_profile" "IAM_profile" {
  name = "IAM_profile"
  role = aws_iam_role.EC2role.name
}


resource "aws_iam_role" "EC2role" {
  name = "EC2role"

  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
EOF
}

resource "aws_iam_policy" "EC2policy" {
  name        = "EC2policy"

  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": [
                  "s3:GetObject",
                  "s3:GetObjectVersion",
                  "s3:ListBucket"
              ],
              "Effect": "Allow",
              "Resource": "*"
          }
        ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "EC2-attach" {
  role       = aws_iam_role.EC2role.name
  policy_arn = aws_iam_policy.EC2policy.arn
}





resource "aws_iam_role" "Codedeploy_role" {
  name = "Codedeploy_role"

  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                  "Service": [
                      "codedeploy.amazonaws.com"
                  ]
              },
              "Action": "sts:AssumeRole"
          }
      ]
  }
EOF
}

resource "aws_iam_policy" "Codedeploy_policy" {
  name        = "Codedeploy_policy"

  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "s3:*",
                  "autoscaling:CompleteLifecycleAction",
                  "autoscaling:DeleteLifecycleHook",
                  "autoscaling:DescribeAutoScalingGroups",
                  "autoscaling:DescribeLifecycleHooks",
                  "autoscaling:PutLifecycleHook",
                  "autoscaling:RecordLifecycleActionHeartbeat",
                  "autoscaling:CreateAutoScalingGroup",
                  "autoscaling:UpdateAutoScalingGroup",
                  "autoscaling:EnableMetricsCollection",
                  "autoscaling:DescribeAutoScalingGroups",
                  "autoscaling:DescribePolicies",
                  "autoscaling:DescribeScheduledActions",
                  "autoscaling:DescribeNotificationConfigurations",
                  "autoscaling:DescribeLifecycleHooks",
                  "autoscaling:SuspendProcesses",
                  "autoscaling:ResumeProcesses",
                  "autoscaling:AttachLoadBalancers",
                  "autoscaling:PutScalingPolicy",
                  "autoscaling:PutScheduledUpdateGroupAction",
                  "autoscaling:PutNotificationConfiguration",
                  "autoscaling:PutLifecycleHook",
                  "autoscaling:DescribeScalingActivities",
                  "autoscaling:DeleteAutoScalingGroup",
                  "ec2:DescribeInstances",
                  "ec2:DescribeInstanceStatus",
                  "ec2:TerminateInstances",
                  "tag:GetResources",
                  "sns:Publish",
                  "cloudwatch:DescribeAlarms",
                  "cloudwatch:PutMetricAlarm",
                  "elasticloadbalancing:DescribeLoadBalancers",
                  "elasticloadbalancing:DescribeInstanceHealth",
                  "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                  "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                  "elasticloadbalancing:DescribeTargetGroups",
                  "elasticloadbalancing:DescribeTargetHealth",
                  "elasticloadbalancing:RegisterTargets",
                  "elasticloadbalancing:DeregisterTargets"
              ],
              "Resource": "*"
          }
      ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "Codedeploy-attach" {
  role       = aws_iam_role.Codedeploy_role.name
  policy_arn = aws_iam_policy.Codedeploy_policy.arn
}



resource "aws_elb" "WebServerLBc" {
  name               = "WebServerLBc"
  availability_zones = ["us-east-2b"]
  security_groups = [aws_security_group.WebServer.id]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 2
    target              = "HTTP:80/index.php"
    interval            = 5
  }

    cross_zone_load_balancing   = true
    idle_timeout                = 300
    connection_draining         = true
    connection_draining_timeout = 300

  tags = {
    Name = "WebServerLBc"
  }
}




resource "aws_eip" "IP" {
  vpc = true
}


resource "aws_lb" "WebServerLB" {
  name               = "WebServerLB"
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = "subnet-d8d4f9a2"
    allocation_id = aws_eip.IP.id
  }
  }


  resource "aws_lb_listener" "LBlistener" {
    load_balancer_arn       = aws_lb.WebServerLB.arn
        port                = 80
        protocol            = "TCP"
        default_action {
          target_group_arn = aws_lb_target_group.TargetGroup.arn
          type             = "forward"
        }
  }



resource "aws_lb_target_group" "TargetGroup" {
  name     = "TargetGroup"
  port     = 80
  protocol = "TCP"
  vpc_id   = "vpc-7de92616"
}
