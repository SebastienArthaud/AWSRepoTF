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