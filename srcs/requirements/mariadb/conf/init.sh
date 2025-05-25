#!/bin/bash

# Vérification des variables d'environnement
if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ] || [ -z "$SQL_ROOT_PASSWORD" ]; then
    echo "ERREUR: Variables d'environnement manquantes."
    exit 1
fi

# Initialisation si le dossier mysql system n'existe pas
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Démarrage temporaire sans auth
echo "Démarrage temporaire de MySQL (mode sans authentification)..."
mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-grant-tables --skip-networking &
MYSQL_PID=$!

# Attente que MySQL soit prêt
echo "Attente du démarrage de MySQL..."
while ! mysqladmin ping --silent; do
    sleep 1
done

echo "MySQL démarré, configuration en cours..."
mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
mysql -e "CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
mysql -e "FLUSH PRIVILEGES;"

echo "Configuration terminée. Arrêt du serveur temporaire..."
kill $MYSQL_PID
wait $MYSQL_PID

# Redémarrage propre de MySQL
echo "Démarrage de MySQL en mode production..."
exec mysqld --user=mysql --datadir=/var/lib/mysql

