FROM	debian:bookworm

# Mise à jour et installation de MariaDB
RUN		apt update -y && \
		apt upgrade -y && \
		apt install -y mariadb-server

# Copie de la configuration MariaDB personnalisée
COPY	conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copie du script d'initialisation
COPY	conf/init.sh /init.sh

# Donne les droits d'exécution au script
RUN		chmod +x /init.sh

# Lancement de MariaDB via le script
CMD		["/init.sh"]
