FROM debian:bookworm

# Mise à jour et installation de PHP, MariaDB client et wget
RUN		apt update -y && \
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
			netcat-openbsd && rm -rf /var/lib/apt/lists/*

# Téléchargement et installation de WordPress
RUN		wget https://fr.wordpress.org/wordpress-6.8.1-fr_FR.tar.gz -P /var/www && \
		tar -xzf /var/www/wordpress-6.8.1-fr_FR.tar.gz -C /var/www && \
		rm /var/www/wordpress-6.8.1-fr_FR.tar.gz

RUN		chown -R www-data:www-data /var/www/wordpress

COPY	conf/www.conf /etc/php/7.3/fpm/pool.d/www.conf

# Télécharger WP-CLI
RUN		curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
		chmod +x wp-cli.phar && \
		mv wp-cli.phar /usr/local/bin/wp

# Setup la config de wordpress
COPY conf/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

CMD ["/usr/local/bin/setup.sh"]
