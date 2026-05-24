#!/bin/sh

# =============================================================
# Script d'initialisation de MariaDB
# Ce script s'exécute à chaque démarrage du conteneur.
# Il vérifie si la base de données existe déjà ou non.
# NOTE : On utilise #!/bin/sh car Alpine n'a pas bash (trop lourd)
# =============================================================

# Crée le répertoire pour le socket MySQL (nécessaire pour que MariaDB démarre)
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Vérifie si la base de données a déjà été initialisée
# (le dossier "mysql" dans /var/lib/mysql est créé lors de la première initialisation)
if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "🔧 Première initialisation de MariaDB..."

    # Initialise les tables système de MariaDB
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Démarre MariaDB temporairement pour exécuter nos commandes SQL
    mysqld --user=mysql --bootstrap << EOF

-- Utilise la base de données système
USE mysql;
FLUSH PRIVILEGES;

-- Supprime les utilisateurs anonymes (sécurité)
DELETE FROM user WHERE User='';

-- Crée la base de données pour WordPress
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Crée l'utilisateur WordPress avec son mot de passe
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

-- Donne tous les droits à cet utilisateur sur la base WordPress
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Change le mot de passe root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Applique les changements
FLUSH PRIVILEGES;
EOF

    echo "✅ Base de données initialisée avec succès"
else
    echo "📁 Base de données déjà initialisée"
fi

# Lance MariaDB au premier plan (pas en daemon)
# --user=mysql : lance en tant qu'utilisateur mysql (sécurité)
# exec : remplace le shell par MariaDB (Docker surveille ce processus)
echo "🚀 Démarrage de MariaDB..."
exec mariadbd --user=mysql
