FROM debian:bookworm

# Mise à jour et installation des paquets nécessaires
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y \
        wget \
        curl \
        php \
        php-fpm \
        php-mysql \
        mariadb-client \
        unzip \
        less \
        netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Corrige l'absence de lien symbolique vers php-fpm
RUN ln -s /usr/sbin/php-fpm8.2 /usr/local/bin/php-fpm

# Installation de WordPress
RUN wget https://fr.wordpress.org/wordpress-6.8.1-fr_FR.tar.gz -P /var/www && \
    tar -xzf /var/www/wordpress-6.8.1-fr_FR.tar.gz -C /var/www && \
    rm /var/www/wordpress-6.8.1-fr_FR.tar.gz && \
    chown -R www-data:www-data /var/www/wordpress

# Configuration PHP-FPM (version 8.2 sur Debian Bookworm)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Installation de WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Script d'installation WordPress
COPY conf/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Lancement du script de configuration
CMD ["/usr/local/bin/setup.sh"]

