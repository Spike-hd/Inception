#!/bin/bash

# Check required environment variables
if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ] || [ -z "$SQL_ROOT_PASSWORD" ]; then
    echo "❌ ERREUR: Variables d'environnement manquantes"
    exit 1
fi

# Initialize DB if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🔄 Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db
fi

# Always start MariaDB in safe mode for setup
echo "🚀 Lancement temporaire de MariaDB pour configuration..."
mysqld_safe --datadir=/var/lib/mysql --skip-networking &
pid="$!"

until mysqladmin ping --silent; do
    sleep 1
done

echo "✅ MariaDB en cours d'exécution"

# Always attempt to configure users and database
echo "⚙️ Configuration des utilisateurs et de la base..."

mysql -uroot <<-EOSQL || mysql -uroot -p"${SQL_ROOT_PASSWORD}" <<-EOSQL
    -- Set root password
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}'
        PASSWORD EXPIRE NEVER
        ACCOUNT UNLOCK;

    CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;

    -- Recreate users to ensure correct password
    DROP USER IF EXISTS '${SQL_USER}'@'%';
    DROP USER IF EXISTS '${SQL_USER}'@'localhost';

    CREATE USER '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
    CREATE USER '${SQL_USER}'@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';

    GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
    GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'localhost';

    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

    FLUSH PRIVILEGES;
EOSQL

# Shut down temp MariaDB
echo "🛑 Arrêt temporaire de MariaDB..."
mysqladmin -uroot -p"${SQL_ROOT_PASSWORD}" shutdown

# Start MariaDB normally
echo "🚀 Démarrage final de MariaDB..."
exec mysqld --user=mysql --console


