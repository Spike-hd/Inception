FROM debian:bookworm

# Installation de MariaDB
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copie de la configuration MariaDB personnalisée
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copie du script d'initialisation
COPY conf/init.sh /init.sh
RUN chmod +x /init.sh

# Lance le script à l'exécution
ENTRYPOINT ["bash", "/init.sh"]


