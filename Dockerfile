FROM debian:latest

RUN apt-get update && \
    apt-get install -y apache2 elinks && \
    rm -rf /var/lib/apt/lists/*

COPY christopher.html /var/www/html/christopher.html

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]