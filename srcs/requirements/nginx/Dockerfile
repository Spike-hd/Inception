FROM	debian:bookworm

RUN		apt update -y && \
		apt upgrade -y && \
		apt install -y openssl nginx vim curl && \
		mkdir -p /etc/nginx/ssl && \
		openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/C=FR/ST=Occitanie/L=Perpignan/O=42/OU=42/CN=hduflos.42.fr" && \
		mkdir -p /var/run/nginx && \
		chmod -R 755 /var/www/html

COPY	conf/nginx.conf /etc/nginx/nginx.conf

CMD		[ "nginx", "-g", "daemon off;" ]

