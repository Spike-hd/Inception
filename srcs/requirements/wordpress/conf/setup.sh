#!/bin/bash

cd /var/www/wordpress

# Attendre que MariaDB soit prêt
until mysqladmin ping -h"$SQL_HOST" --silent; do
	echo "En attente de MariaDB..."
	sleep 2
done

# Si wp-config.php n'existe pas, on crée la config et on installe WordPress
if [ ! -f wp-config.php ]; then
	echo "Création de wp-config.php..."

# Créer le fichier de configuration wp-config.php
wp config create \
  --dbname=$SQL_DATABASE \
  --dbuser=$SQL_USER \
  --dbpass=$SQL_PASSWORD \
  --dbhost=mariadb:3306 \
  --path=/var/www/wordpress \
  --allow-root

# Installer WordPress
wp core install \
  --url=$DOMAIN_NAME \
  --title="Mon super site" \
  --admin_user=$WP_ADMIN_USER \
  --admin_password=$WP_ADMIN_PASSWORD \
  --admin_email=$WP_ADMIN_EMAIL \
  --skip-email \
  --allow-root


	echo "✅ WordPress installé avec succès."
else
	echo "WordPress est déjà configuré."
fi

# Démarrer PHP-FPM en avant-plan
echo "🚀 Lancement de PHP-FPM..."
exec php-fpm7.3 -F
