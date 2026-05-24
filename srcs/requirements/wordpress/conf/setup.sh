#!/bin/sh
set -e

# =============================================================
# Script d'initialisation de WordPress
# Ce script :
# 1. Télécharge WordPress si pas déjà fait
# 2. Configure la connexion à MariaDB
# 3. Installe WordPress (crée l'admin)
# 4. Lance PHP-FPM
# set -e = arrête le script dès qu'une commande échoue
# =============================================================

# Attend que MariaDB soit prête (elle met quelques secondes à démarrer)
echo "Attente de MariaDB..."
while ! nc -z mariadb 3306 2>/dev/null; do
    sleep 1
done
echo "MariaDB est prête !"

# Va dans le dossier web
cd /var/www/html

# Vérifie si WordPress est déjà installé
if [ ! -f "wp-config.php" ]; then

    echo "🔧 Installation de WordPress..."

    # Télécharge les fichiers WordPress
    wp core download --allow-root

    # Crée le fichier wp-config.php avec les infos de connexion à MariaDB
    # Ces variables viennent du fichier .env via docker-compose
    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb"

    # Installe WordPress (crée les tables dans MariaDB + le compte admin)
    wp core install --allow-root \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    # Crée un deuxième utilisateur (demandé par le sujet)
    wp user create --allow-root \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}"

    echo "WordPress installé avec succès !"
else
    echo "WordPress déjà installé"
fi

# Lance PHP-FPM au premier plan (comme mariadbd pour MariaDB)
echo "🚀 Démarrage de PHP-FPM..."
exec php-fpm81 -F