
!!!!!!!!!WARNING!!!!!!!!!
You'll need your AWS account ACCESS_KEY and SECRET_KEY to access your account with Terraform.
The Key pair for your EC2 instances has to be created too.
!!!!!!!!!!!!!!!!!!!!!!!!!

1.Go to the "Pre-Configuration" folder
2.Execute the code with Terraform, VPC, subnets, EFS storage and security groups will be crated.
3.THen go to the "Instance0_installation" folder
4.Execute the Terraform code. The first instance with the wordpress configuration and EFS storage will be set.
5.For the last step, go to the "HAConfiguration" folder and launch the code. A launch configuration, an auto-scaling group and an ELB will be created.
6.Launch the WordPress configuration by connecting Application with the ELB DNS name in your web navigator.
7.The APplication is ready 



====================================================================================================================================================================================================FRANCAIS============================================================================================================================================================================================================

!!!!!!!!ATTENTION!!!!!!!!
Les ACCESS_KEY et SECRET_KEY de votre compte AWS sont à saisir dans les variables déclarées
La Key pair est également à créer et à renseigner dans les variables déclarées.
!!!!!!!!!!!!!!!!!!!!!!!!!


1. rendez-vous d'abord dans le dossier "Pre-Configuration"
2. lancez l'éxecution du code avec Terraform, le VPC, les Subnets, le stockage EFS et les groupes de sécurité seront créés.
3. Rendez-vous dans le dossier "Instance0_installation"
4. Lancez l'éxecution du code avec Terraform, l'instance originale sera créée, les fichiers WordPress seront installés sur le stockage EFS (lui-même monté sur /var/www/html)
5. ALlez ensuite dans le dossier "HAConfiguration" et lancez l'éxecution du code. Une Launch Configuration, un groupe AUto-Scaling ainsi qu'un ELB seront créés.
6. Lancez l'installation de Wordpress en vous connectant directement en http à l'adresse DNS de l'ELB (environs 2 minutes)
7. l'application est maintenant opérationnelle
