#############################################################
#HAConfiguration.tf : Configuration de la haute disponibilité
#de l'application avec la création d'un groupe Auto-scaling et
#d'un load balancer
#
# Sébastien ARTHAUD : 06/04/20
###############################################################


# on récupère l'id de notre VPC précédemment créé.
data "aws_vpc" "Get_VPC_Id" {
}

#récupération de l'id du groupe de sécurité destiné aux instances ec2 du groupe Auto-Scaling
#Accès en SSH depuis une adresse IP spécifique autorisé
#Accès en http depuis n'importe quelle adresse IP autorisé
data "aws_security_group" "VPC_Paris_HTTP_SG" {
  vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
  filter {
    name = "tag:Name"
    values = ["VPC_Paris_HTTP_SG"]
  }

}

  data "aws_security_group" "VPC_Paris_ELB_HTTP_SG" {
    vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
    filter {
      name = "tag:Name"
      values = ["VPC_Paris_ELB_HTTP_SG"]
    }

}
##############################################################################
#Récupération des Subnets privates déstinés à configurer le groupe Auto-Scaling
#
#Les machines sont dans des subnets privés pour des raisons de sécurtiés, elle ne devront être accédées que par l'ELB
################################################################################
data "aws_subnet" "Private_Subnet4" {
  vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
  filter {
    name = "tag:Name"
    values = ["VPC_Paris_Private_Subnet_4"]
  }
}

data "aws_subnet" "Private_Subnet5" {
  vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
  filter {
    name = "tag:Name"
    values = ["VPC_Paris_Private_Subnet_5"]
  }
}

data "aws_subnet" "Private_Subnet6" {
  vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
  filter {
    name = "tag:Name"
    values = ["VPC_Paris_Private_Subnet_6"]
  }
}


data "aws_subnet" "Public_Subnet1" {
  vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
  filter {
    name = "tag:Name"
    values = ["VPC_Paris_Public_Subnet_1"]
  }
}

data "aws_subnet" "Public_Subnet2" {
  vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
  filter {
    name = "tag:Name"
    values = ["VPC_Paris_Public_Subnet_2"]
  }
}

data "aws_subnet" "Public_Subnet3" {
  vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
  filter {
    name = "tag:Name"
    values = ["VPC_Paris_Public_Subnet_3"]
  }
}

# récupération de l'id du stockage EFS créé
data "aws_efs_file_system" "file_system" {
}


#######################################################
##########clé publique d'authentifiaction SSH##########
#######################################################




resource "aws_launch_configuration" "VPC_Paris_Launch_Configuration" {
    image_id = "${lookup(var.AMIS, var.REGION)}"
    instance_type = "t2.micro"
    key_name = var.key_name
    security_groups = ["${data.aws_security_group.VPC_Paris_HTTP_SG.id}"]
    root_block_device {
      volume_type = "gp2"
      volume_size = 8
    }
    user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install httpd php php-mysql -y
                yum install amazon-efs-utils -y
                sudo mount -t efs ${data.aws_efs_file_system.file_system.id}:/ /var/www/html
                chkconfig httpd on
                service httpd start
                EOF


    connection {
      user = "ec2-user"
      password = "azerty"
    }


}



resource "aws_autoscaling_group" "VPC_Paris_Auto-scaling" {

    name                      = "VPC_Paris_Auto-scaling"
    max_size                  = 6
    min_size                  = 3
    health_check_grace_period = 300
    health_check_type         = "EC2"
    force_delete              = true
    launch_configuration      = "${aws_launch_configuration.VPC_Paris_Launch_Configuration.name}"
    vpc_zone_identifier = ["${data.aws_subnet.Private_Subnet4.id}", "${data.aws_subnet.Private_Subnet5.id}","${data.aws_subnet.Private_Subnet6.id}"]
    load_balancers = ["${aws_elb.VPC_Paris_ELB.name}"]
}


#for_each = data.aws_autoscaling_group.VPC_Paris_Auto-scaling.name


resource "aws_autoscaling_policy" "VPC_Paris_Auto-scaling_Policy" {
    name                   = "VPC_Paris_Auto-scaling_Policy"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    policy_type            = "SimpleScaling"
    autoscaling_group_name = aws_autoscaling_group.VPC_Paris_Auto-scaling.name


}

resource "aws_cloudwatch_metric_alarm" "Auto-Scaling_Alarm" {
    alarm_name = "Auto-Scaling_Alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "300"
    statistic = "Average"
    threshold = "80"

    dimensions = {
      "AutoScalingGroupName" = "${aws_autoscaling_policy.VPC_Paris_Auto-scaling_Policy.name}"
    }

    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.VPC_Paris_Auto-scaling_Policy.arn}"]

}


resource "aws_elb" "VPC_Paris_ELB" {
    cross_zone_load_balancing   = true
    name               = "VPCParisELB"
    #availability_zones = ["eu-west-3a","eu-west-3b","eu-west-3c"]
    subnets = ["${data.aws_subnet.Public_Subnet1.id}", "${data.aws_subnet.Public_Subnet2.id}","${data.aws_subnet.Public_Subnet3.id}"]
    security_groups = ["${data.aws_security_group.VPC_Paris_ELB_HTTP_SG.id}"]
    listener {
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 10
        timeout             = 20
        target              = "HTTP:80/healthy.html"
        interval            = 30
    }
}
