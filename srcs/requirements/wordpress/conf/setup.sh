#!/bin/bash

cd /var/www/wordpress

echo "Testing database connection..."
echo "User: $SQL_USER"
echo "Database: $SQL_DATABASE"
echo "Host: $SQL_HOST"

# Test connection with proper credentials
until mysqladmin -h"$SQL_HOST" -u"$SQL_USER" -p"$SQL_PASSWORD" ping &>/dev/null; do
    echo "🔄 Waiting for MariaDB... (Trying to connect as $SQL_USER)"
    sleep 5
done

echo "✅ Database connection successful!"

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

	wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--role=author \
		--user_pass="$WP_USER_PASSWORD" \
		--allow-root

	echo "✅ WordPress installé avec succès."
else
	echo "ℹ️ WordPress est déjà configuré."
fi

echo "🚀 Lancement de PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F
