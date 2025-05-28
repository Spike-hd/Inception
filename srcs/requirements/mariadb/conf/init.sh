#!/bin/bash

# Vérification des variables d'environnement
if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ] || [ -z "$SQL_ROOT_PASSWORD" ]; then
    echo "ERREUR: Les variables d'environnement suivantes sont requises:"
    echo "  - SQL_DATABASE"
    echo "  - SQL_USER"
    echo "  - SQL_PASSWORD"
    echo "  - SQL_ROOT_PASSWORD"
    exit 1
fi

# Initialisation de la base de données si nécessaire
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🔄 Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db

    # Créer un fichier SQL temporaire pour l'initialisation
    cat > /tmp/init.sql << EOF
USE mysql;
FLUSH PRIVILEGES;

# Création de la base et de l'utilisateur
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${SQL_USER}'@'wordpress.srcs_inception' IDENTIFIED BY '${SQL_PASSWORD}';

# Attribution des privilèges
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'wordpress.srcs_inception';

# Configuration root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';

# Nettoyage des accès non sécurisés
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;

FLUSH PRIVILEGES;
EOF

    echo "✅ Configuration initiale créée."
fi

# Démarrer MySQL avec le script d'initialisation
echo "🚀 Démarrage de MySQL..."
if [ -f /tmp/init.sql ]; then
    exec mysqld --user=mysql --datadir=/var/lib/mysql --init-file=/tmp/init.sql
else
    exec mysqld --user=mysql --datadir=/var/lib/mysql
fi

