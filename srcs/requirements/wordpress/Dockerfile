# 1. Même base Alpine que MariaDB
FROM alpine:3.18

# 2. On installe :
#    - php81 : le langage PHP (WordPress est écrit en PHP)
#    - php81-fpm : FastCGI Process Manager (le "moteur" qui exécute PHP)
#    - php81-mysqli : extension pour se connecter à MariaDB
#    - php81-json, php81-curl, etc. : extensions requises par WordPress
#    - wget : pour télécharger WordPress
#    - netcat-openbsd : pour tester si MariaDB est prête (commande nc)
RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    php81-redis \
    php81-phar \
    wget \
    netcat-openbsd

# 3. On télécharge WP-CLI (un outil en ligne de commande pour installer WordPress)
#    C'est plus propre que de le faire manuellement
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# 4. On copie la config PHP-FPM (sur quel port écouter, combien de processus...)
COPY conf/www.conf /etc/php81/php-fpm.d/www.conf

# 5. On copie le script d'initialisation de WordPress
COPY conf/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# 6. On crée le dossier où WordPress sera installé
RUN mkdir -p /var/www/html

# 6b. On augmente la limite mémoire de PHP (par défaut 128M, pas assez pour WP-CLI)
RUN echo "memory_limit = 512M" > /etc/php81/conf.d/memory.ini

# 7. PHP-FPM écoute sur le port 9000 (NGINX lui enverra les requêtes PHP)
EXPOSE 9000

# 8. Au démarrage, on lance le script d'installation
CMD ["/usr/local/bin/setup.sh"]

