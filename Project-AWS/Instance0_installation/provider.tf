#############################################################
#provider.tf : Environnement cloud sur lequel nous nous connectons
#
#
#
# Sébastien ARTHAUD : 06/04/20
###############################################################



provider "aws" {
  version = "2.7"
  access_key =  var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region =var.REGION
}
