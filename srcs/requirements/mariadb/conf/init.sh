#!/bin/bash

# Démarrer MySQL
service mysql start

# Créer la base de données si elle n'existe pas
mysql -e "CREATE DATABASE IF NOT EXISTS ${SQL_DATABASE};"

# Créer un utilisateur et lui donner les droits
mysql -e "CREATE USER IF NOT EXISTS ${SQL_USER}@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO ${SQL_USER}@'%' IDENTIFIED BY '${SQL_PASSWORD}';"

# Modifier le mot de passe de l'utilisateur root
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

# Rafraîchir les privilèges
mysql -e "FLUSH PRIVILEGES;"

# Stop la base de donnée
mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown

#lance son execution
exec mysqld_safe
