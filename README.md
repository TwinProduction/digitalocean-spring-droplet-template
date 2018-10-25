# digitalocean-spring-droplet-template

As the name more or less implies, this repository is a template of the necessary 
dependencies required to run a spring boot application on a fresh droplet.

For now, the initial configuration is expected to be the following:

- Ubuntu 18.04 x64

Later on, perhaps support for different distributions will be added.


## What does it do

- Installs the latest JDK
- Generates a LetsEncrypt TLS certificate using certbot
- Installs Nginx to use as reverse proxy for SSL/TLS termination 

Nginx will listen to port 80 and port 443. 
- If the port is 80, then the user will be redirected to port 443.
- If the port is 443, then the user will see where Nginx' reverse proxy is pointing to, 
which is the port your application is bound to.


## Requirements

Your application must listen on the port 8080.