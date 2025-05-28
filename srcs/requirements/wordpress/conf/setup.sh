#!/bin/bash

cd /var/www/wordpress

# Attendre que MariaDB soit prêt et tester la connexion
until mariadb -h mariadb -u"$SQL_USER" -p"$SQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "🔄 En attente de MariaDB..."
    sleep 5
done

# Si wp-config.php n'existe pas, on crée la config et on installe WordPress
if [ ! -f wp-config.php ]; then
    echo "📝 Création de wp-config.php..."

    wp config create \
        --dbname="$SQL_DATABASE" \
        --dbuser="$SQL_USER" \
        --dbpass="$SQL_PASSWORD" \
        --dbhost=mariadb \
        --path=/var/www/wordpress \
        --allow-root

    wp core install \
        --url="$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "✅ WordPress installé avec succès."
else
    echo "ℹ️ WordPress est déjà configuré."
fi

echo "🚀 Lancement de PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F
