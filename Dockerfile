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
        supervisor

# Install mysql
RUN echo mysql-server mysql-server/root_password password magento2 | debconf-set-selections;\
    echo mysql-server mysql-server/root_password_again password magento2 | debconf-set-selections;\
    apt-get install -y mysql-server mysql-client

RUN usermod -d /var/lib/mysql/ mysql
ADD ./conf/bind_0.cnf /etc/mysql/conf.d/bind_0.cnf

RUN mkdir -p /opt/mysql
ADD bin/run_mysql.sh /opt/mysql/run_mysql.sh
RUN chmod 755 /opt/mysql/run_mysql.sh

VOLUME ["/var/lib/mysql"]

# install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    printf "\nPATH=\"~/.composer/vendor/bin:\$PATH\"\n" | tee -a ~/.bashrc


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
 
EXPOSE 80 443 3306
