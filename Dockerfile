FROM debian:jessie
MAINTAINER Carlinhos Lehn <carlos@carlinhoslehn.com>

# Install base packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -yq install \
        curl \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql \
        php5-mcrypt \
        php5-gd \
        php5-curl \
        php5-xdebug \
        php-pear \
	vim \
	wget \
        php-apc && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN /usr/sbin/php5enmod mcrypt
RUN a2enmod headers
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" /etc/php5/apache2/php.ini && \
    sed -i "s/display_errors = Off/display_errors = On/g" /etc/php5/apache2/php.ini && \
    sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini

RUN echo "zend_extension=xdebug.so" > /etc/php5/apache2/php.ini \
&& echo "xdebug.remote_enable=on"  >> /etc/php5/mods-available/xdebug.ini \
&& echo "xdebug.remote_host=localhost" >> /etc/php5/mods-available/xdebug.ini \
&& echo "xdebug.profiler_enable=1" >> /etc/php5/mods-available/xdebug.ini \
&& echo "xdebug.remote_port=9001" >> /etc/php5/mods-available/xdebug.ini \
&& echo "xdebug.remote_connect_back=On" >> /etc/php5/mods-available/xdebug.ini \
&& echo "memory_limit = 64M" > /etc/php5/apache2/php.ini


ENV ALLOW_OVERRIDE **true**

# Add image configuration and scripts
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD app/ /app

EXPOSE 80 9001
WORKDIR /app
CMD ["/run.sh"]
