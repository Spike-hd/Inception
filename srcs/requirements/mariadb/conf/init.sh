#!/bin/bash

if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ] || [ -z "$SQL_ROOT_PASSWORD" ]; then
    echo "ERREUR: Variables d'environnement manquantes"
    exit 1
fi

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🔄 Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db

    # Initialisation avec bootstrap
    mysqld --bootstrap --user=mysql --datadir=/var/lib/mysql << EOF
USE mysql;
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;

# Création des utilisateurs
CREATE USER '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
CREATE USER '${SQL_USER}'@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';

# Attribution des privilèges
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';

# Nettoyage
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

    echo "✅ Base de données initialisée"
fi

echo "🚀 Démarrage de MariaDB..."
exec mysqld --user=mysql --console

