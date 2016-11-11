#Download base image ubuntu 16.04
FROM ubuntu:16.04
 
# Update Software repository
RUN apt-get update
 
# Install nginx, php-fpm and supervisord from ubuntu repository
RUN apt-get install -y \
        nginx \
        php7.0-fpm \
        php7.0-mcrypt \
        php7.0-curl \
        php7.0-cli \
        php7.0-mysql \
        php7.0-gd \
        php7.0-xsl \
        php7.0-json \
        php7.0-intl \
        php-pear \
        php7.0-dev \
        php7.0-common \
        php7.0-mbstring \
        php7.0-zip \
        php-soap \
        libcurl3 \
        curl \
        supervisor && \
    rm -rf /var/lib/apt/lists/*
 
#Define the ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.0/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf
 
# Enable php-fpm on nginx virtualhost configuration
COPY ./conf/default.conf ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}
 
#Copy supervisor configuration
COPY ./conf/supervisord.conf ${supervisor_conf}
 
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php
 
# Volume configuration
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]
 
# Configure Services and Port
COPY ./bin/start.sh /start.sh
CMD ["./start.sh"]
 
EXPOSE 80 443
