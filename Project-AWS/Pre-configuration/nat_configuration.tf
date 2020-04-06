#############################################################
#nat_configuration.tf : Configuration de la NAT Gateway, l'EIP et la
#table de routage.
#
#
# Sébastien ARTHAUD : 06/04/20
###############################################################


resource "aws_eip" "nat_IP" {
    vpc = true
}


#Création du nat gateway
resource "aws_nat_gateway" "VPC_Paris_Nat_Gateway" {
   allocation_id = "${aws_eip.nat_IP.id}"
   subnet_id = "${aws_subnet.VPC_Paris_Public_Subnet_1.id}"
   depends_on = ["aws_internet_gateway.VPC_Paris_IGW"]
}


#une route est créée vers la nat gateway pour sortir vers internet
resource "aws_route_table" "VPC_Paris_Private_RT" {
    vpc_id = "${aws_vpc.VPC_Paris.id}"

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.VPC_Paris_Nat_Gateway.id}"
    }
}

#On associe les Subnets privés avec la route table. (but : que les instances puissent réaliser des mises à jour)
resource "aws_route_table_association" "Association_PrivateSB_PrivateRT1" {
    route_table_id = "${aws_route_table.VPC_Paris_Private_RT.id}"
    subnet_id = "${aws_subnet.VPC_Paris_Private_Subnet_4.id}"
}

resource "aws_route_table_association" "Association_PrivateSB_PrivateRT2" {
    route_table_id = "${aws_route_table.VPC_Paris_Private_RT.id}"
    subnet_id = "${aws_subnet.VPC_Paris_Private_Subnet_5.id}"
}

resource "aws_route_table_association" "Association_PrivateSB_PrivateRT3" {
    route_table_id = "${aws_route_table.VPC_Paris_Private_RT.id}"
    subnet_id = "${aws_subnet.VPC_Paris_Private_Subnet_6.id}"
}
