#############################################################
#Instance0.tf : Création de l'instance 0 qui va configurer le stockage EFS
#et installer les fichiers Wordpress dedans. Le stockage sera monté
#sur le répertoire /var/www/html
#
# Sébastien ARTHAUD : 06/04/20
###############################################################


# on récupère l'id de notre VPC précédemment créé.
data "aws_vpc" "Get_VPC_Id" {
}

#récupération de l'id du groupe de sécurité destinés à l'instance ec2
#Accès en SSH depuis une adresse IP spécifique autorisé
#Accès en http depuis n'importe quelle adresse IP autorisé
data "aws_security_group" "VPC_Paris_SSH_HTTP_SG" {
  vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
  filter {
    name = "tag:Name"
    values = ["VPC_Paris_SSH_HTTP_SG"]
  }

}

#Récupération du Subnet public déstiné à installer l'instance "0" (installation wordpress sur le stockage EFS)
data "aws_subnet_ids" "Public_Subnet1" {
  vpc_id = "${data.aws_vpc.Get_VPC_Id.id}"
  filter {
    name = "tag:Name"
    values = ["VPC_Paris_Public_Subnet_1"]
  }
}

# récupération de l'id du stockage EFS créé
data "aws_efs_file_system" "file_system" {

}


#######################################################
##########clé publique d'authentifiaction SSH##########
#######################################################
resource "aws_key_pair" "Mykeypair" {
  key_name = "Mykeypair"
  public_key = "${file("Mykeypair.pem")}"

}


#####################################################################
#####################Création de l'instance originale################
#####################################################################
resource "aws_instance" "VPC_Paris_Web_Server_0" {
    ami = "${lookup(var.AMIS, var.REGION)}"
    instance_type = "t2.micro"
    key_name = aws_key_pair.Mykeypair.key_name
    availability_zone = "eu-west-3a"
    for_each = data.aws_subnet_ids.Public_Subnet1.ids
    subnet_id = each.value
    vpc_security_group_ids = ["${data.aws_security_group.VPC_Paris_SSH_HTTP_SG.id}"]
    associate_public_ip_address = true
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
                chmod 777 /var/www/html
                cd /var/www/html
                echo "healthy" > healthy.html
                wget https://wordpress.org/wordpress-5.1.1.tar.gz
                tar -xzf wordpress-5.1.1.tar.gz
                cp -r wordpress/* /var/www/html/
                rm -rf wordpress
                rm -rf wordpress-5.1.1.tar.gz
                chmod -R 755 wp-content
                chown -R apache:apache wp-content
                wget https://s3.amazonaws.com/bucketforwordpresslab-donotdelete/htaccess.txt
                mv htaccess.txt .htaccess
                chkconfig httpd on
                service httpd start
                EOF


    connection {
      user = "ec2-user"
    }




}
