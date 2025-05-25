#!/bin/bash

# Initialisation de la base de données si nécessaire
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Démarrer MySQL en arrière-plan pour la configuration initiale
mysqld_safe --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!

# Attendre que MySQL soit prêt
echo "Attente du démarrage de MySQL..."
while ! mysqladmin ping --silent; do
    sleep 1
done

echo "MySQL démarré, configuration en cours..."

# Configuration de la base de données
mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
mysql -e "CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
mysql -e "FLUSH PRIVILEGES;"

echo "Configuration terminée."

# Arrêter le processus temporaire
mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown
wait $MYSQL_PID

# Démarrer MySQL en mode production (premier plan)
echo "Démarrage de MySQL en mode production..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
