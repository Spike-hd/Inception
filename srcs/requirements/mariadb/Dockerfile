# 1. On part d'Alpine 3.18 (avant-dernière version stable, léger ~5 Mo)
FROM alpine:3.18

# 2. On installe MariaDB avec apk (le gestionnaire de paquets d'Alpine)
#    - apk update : met à jour la liste des paquets
#    - apk add --no-cache : installe sans garder le cache (image plus légère)
#    - mariadb : le serveur MariaDB
#    - mariadb-client : les outils en ligne de commande (mysql, mysqldump...)
RUN apk update && \
    apk add --no-cache mariadb mariadb-client

# 2b. On supprime la config par défaut d'Alpine qui contient "skip-networking"
#     (skip-networking = pas de connexion réseau = port 0 = WordPress ne peut pas se connecter !)
RUN rm -f /etc/my.cnf.d/mariadb-server.cnf

# 3. On copie notre fichier de configuration MariaDB dans le conteneur
#    Sur Alpine, le dossier de config est /etc/my.cnf.d/ (pas /etc/mysql/)
COPY conf/50-server.cnf /etc/my.cnf.d/50-server.cnf

# 4. On copie notre script d'initialisation (création de la base et des utilisateurs)
COPY conf/init.sh /etc/mysql/init.sh

# 5. On rend le script exécutable
RUN chmod +x /etc/mysql/init.sh

# 6. On expose le port 3306 (port standard de MySQL/MariaDB)
EXPOSE 3306

# 7. Au démarrage du conteneur, on lance notre script d'initialisation
CMD ["/etc/mysql/init.sh"]

