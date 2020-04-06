#############################################################
#variables.tf
#
#
#
# Sébastien ARTHAUD : 06/04/20
###############################################################


variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "REGION" {
  default = "eu-west-3"
}

variable "IP_Address_SSH" {
}

# Variable map des différents ID EC2 en fonction des regions eu-west
variable "AMIS" {
  type = "map"
  default = {
    eu-west-1 = "ami-049456450f2873c0a"
    eu-west-2 = "ami-0cb790308f7591fa6"
    eu-west-3 = "ami-07eda9385feb1e969"
  }
}
