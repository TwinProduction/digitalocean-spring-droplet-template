#!/usr/bin/env bash

if [ "$1" = "" ]; then
	echo "USAGE: ./install.sh domain port"
	echo "e.g. ./install.sh twinnation.org 8080"
	exit 1
fi

domain=$1
application_port=$2

# Install the latest JDK
apt install -y default-jdk

# TESTING vvv
pkill -f "java"
wget https://github.com/TwinProduction/spring-as-backend/releases/download/v0.0.3/spring-as-backend.jar
java -jar spring-as-backend.jar > /dev/nul &
# TESTING ^^^

apt update


####################################################
# SSL/TLS termination using Nginx as reverse proxy #
####################################################

apt install -y nginx

# Nginx needs to be stopped for certbot's http challenge
service nginx stop
pkill -f "nginx"

# Make sure that port 80 and 443 aren't blocked by the firewall
ufw allow 80/tcp
ufw allow 443/tcp

# Install certbot to generate a certificate with LetsEncrypt
add-apt-repository -y ppa:certbot/certbot
apt update
apt install -y certbot python-certbot-nginx
certbot --nginx --preferred-challenges http -d ${domain} --register-unsafely-without-email --agree-tos --redirect

nginx_config="
server {
    server_name $domain;
    location / {
        proxy_pass http://localhost:$application_port;
        proxy_read_timeout 90s;
    }
    listen [::]:443 ssl ipv6only=on;
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

server {
    server_name $domain;
    listen 80;
    listen [::]:80;
    return 301 https://\$host\$request_uri;
}
"

echo "$nginx_config" | tee /etc/nginx/sites-available/default > /dev/null

service nginx start