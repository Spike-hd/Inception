FROM debian:bookworm

# Installation de MariaDB
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Création des répertoires nécessaires et configuration des permissions
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql

# Copie de la configuration MariaDB personnalisée
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copie du script d'initialisation
COPY conf/init.sh /init.sh
RUN chmod +x /init.sh

# Exposition du port
EXPOSE 3306

# Lance le script à l'exécution
ENTRYPOINT ["bash", "/init.sh"]


