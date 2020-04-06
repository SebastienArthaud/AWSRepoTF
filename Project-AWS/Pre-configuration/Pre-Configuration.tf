#############################################################
#Pre-Configuration.tf : Configuration VPC, SUbnets (privés et publics),
#groupes de sécurité, base de données mariadb et EFS
#
#
# Sébastien ARTHAUD : 06/04/20
###############################################################



#Création du VPC de Paris dans lequel sera configurée notre infrastructure WordPress
resource "aws_vpc" "VPC_Paris" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    instance_tenancy = "default"

    tags = {
      Name = "VPC_Paris"
    }
}


#Création des subnets publics (adresse IP publique attribuée + association avec une route table publique)
###########################################################################################################
resource "aws_subnet" "VPC_Paris_Public_Subnet_1" {
    availability_zone = "eu-west-3a"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    tags = {
      Name = "VPC_Paris_Public_Subnet_1"
    }
}

resource "aws_subnet" "VPC_Paris_Public_Subnet_2" {
    availability_zone = "eu-west-3b"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    tags = {
      Name = "VPC_Paris_Public_Subnet_2"
    }
}


resource "aws_subnet" "VPC_Paris_Public_Subnet_3" {
    availability_zone = "eu-west-3c"
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = true
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    tags = {
      Name = "VPC_Paris_Public_Subnet_3"
    }
}


#Création des Subnets privés
resource "aws_subnet" "VPC_Paris_Private_Subnet_4" {
    availability_zone = "eu-west-3a"
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = false
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    tags = {
      Name = "VPC_Paris_Private_Subnet_4"
    }
}

resource "aws_subnet" "VPC_Paris_Private_Subnet_5" {
    availability_zone = "eu-west-3b"
    cidr_block = "10.0.5.0/24"
    map_public_ip_on_launch = false
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    tags = {
      Name = "VPC_Paris_Private_Subnet_5"
    }
}


resource "aws_subnet" "VPC_Paris_Private_Subnet_6" {
    availability_zone = "eu-west-3c"
    cidr_block = "10.0.6.0/24"
    map_public_ip_on_launch = false
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    tags = {
      Name = "VPC_Paris_Private_Subnet_6"
    }
}

#création d'une Internet Gateway (accès vers internet et depuis internet autorisés)
resource "aws_internet_gateway" "VPC_Paris_IGW" {
    vpc_id = "${aws_vpc.VPC_Paris.id}"
}


# création table de routage publique destinée aux Subnets publics
resource "aws_route_table" "VPC_Paris_Public_RT" {
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    route {
      gateway_id = "${aws_internet_gateway.VPC_Paris_IGW.id}"
      cidr_block = "0.0.0.0/0"
    }
}

#Association de la tables de routage avec les subnets publics
resource "aws_route_table_association" "Association_PublicSB_PublicRT1" {
    route_table_id = "${aws_route_table.VPC_Paris_Public_RT.id}"
    subnet_id = "${aws_subnet.VPC_Paris_Public_Subnet_1.id}"
}

resource "aws_route_table_association" "Association_PublicSB_PublicRT2" {
    route_table_id = "${aws_route_table.VPC_Paris_Public_RT.id}"
    subnet_id = "${aws_subnet.VPC_Paris_Public_Subnet_2.id}"
}

resource "aws_route_table_association" "Association_PublicSB_PublicRT3" {
    route_table_id = "${aws_route_table.VPC_Paris_Public_RT.id}"
    subnet_id = "${aws_subnet.VPC_Paris_Public_Subnet_3.id}"
}



#######################################################################
####################GROUPES DE SECURITE################################
#######################################################################
resource "aws_security_group" "RDS_security_Group" {
  vpc_id = "${aws_vpc.VPC_Paris.id}"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "TCP"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS_security_Group"
  }
}

#Création du Security group déstinés aux serveurs (instances EC2) hébergeant la future application web Wordpress
#Accès en SSH depuis une adresse IP spécifique autorisé
#Accès en http depuis n'importe quelle adresse IP autorisé
resource "aws_security_group" "VPC_Paris_SSH_HTTP_SG" {
    vpc_id = "${aws_vpc.VPC_Paris.id}"
    ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      cidr_blocks = ["${var.IP_Address_SSH}"]
    }

    ingress {
      from_port = 80
      to_port = 80
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "VPC_Paris_SSH_HTTP_SG"
    }
}


resource "aws_security_group" "VPC_Paris_ELB_HTTP_SG" {
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    ingress {
      from_port = 80
      to_port = 80
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "VPC_Paris_ELB_HTTP_SG"
    }
}

resource "aws_security_group" "VPC_Paris_HTTP_SG" {
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    ingress {
      from_port = 80
      to_port = 80
      protocol = "TCP"
      security_groups = ["${aws_security_group.VPC_Paris_ELB_HTTP_SG.id}","${aws_security_group.VPC_Paris_SSH_HTTP_SG.id}"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "VPC_Paris_HTTP_SG"
    }
}








################################################################
#Groupes de subnets dans lesquels l'instance RDS pourra être répliquée en cas d'activation du HA
################################################################
resource "aws_db_subnet_group" "RDS_Subnet_Group" {
    name = "subnet_group"
    description = "DB SUbnet Group"
    subnet_ids = ["${aws_subnet.VPC_Paris_Private_Subnet_4.id}","${aws_subnet.VPC_Paris_Private_Subnet_5.id}","${aws_subnet.VPC_Paris_Private_Subnet_6.id}"]
}


#création de l'instance RDS avec le moteur DB mariadb
resource "aws_db_instance" "mariadb" {
    allocated_storage = 100
    engine = "mariadb"
    engine_version = "10.2"
    instance_class = "db.t2.micro"
    identifier = "mariadb"
    name = "mariadb"
    username = "root"
    password = "!Azerty001"
    db_subnet_group_name = "${aws_db_subnet_group.RDS_Subnet_Group.name}"

    #Database en HA
    multi_az = true

    vpc_security_group_ids = ["${aws_security_group.RDS_security_Group.id}"]
    storage_type = "gp2"
    backup_retention_period = 7
    #availability_zone = "${aws_subnet.VPC_Paris_Private_Subnet_4.availability_zone}"
}



resource "aws_security_group" "VPC_Paris_NFS_SG" {
    vpc_id = "${aws_vpc.VPC_Paris.id}"
    ingress {
      from_port = 2049
      to_port = 2049
      protocol = "TCP"
      security_groups = ["${aws_security_group.VPC_Paris_SSH_HTTP_SG.id}","${aws_security_group.VPC_Paris_HTTP_SG.id}"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "VPC_Paris_NFS_SG"
    }
}


##############################################################
###################CREATION EFS###############################
##############################################################
resource "aws_efs_file_system" "VPC_Paris_EFS" {
  creation_token = "WPDATA"

  tags = {
    Name = "WPDATA_EFS"
  }
}


#######################################################################
#################Association EFS - Availability Zones##################
#######################################################################
resource "aws_efs_mount_target" "EFS_Mount_1" {
  file_system_id = "${aws_efs_file_system.VPC_Paris_EFS.id}"
  subnet_id      = "${aws_subnet.VPC_Paris_Private_Subnet_4.id}"
  security_groups = ["${aws_security_group.VPC_Paris_NFS_SG.id}"]
}

resource "aws_efs_mount_target" "EFS_Mount_2" {
  file_system_id = "${aws_efs_file_system.VPC_Paris_EFS.id}"
  subnet_id      = "${aws_subnet.VPC_Paris_Private_Subnet_5.id}"
  security_groups = ["${aws_security_group.VPC_Paris_NFS_SG.id}"]
}

resource "aws_efs_mount_target" "EFS_Mount_3" {
  file_system_id = "${aws_efs_file_system.VPC_Paris_EFS.id}"
  subnet_id      = "${aws_subnet.VPC_Paris_Private_Subnet_6.id}"
  security_groups = ["${aws_security_group.VPC_Paris_NFS_SG.id}"]
}
