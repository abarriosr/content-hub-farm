FROM alpine:latest
VOLUME /var/www/html

RUN set -x \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk update && apk upgrade \
  && apk add --update \
    supervisor \
    nginx \
    curl \
    bash \
    pv \
    mysql \
    mysql-client \
    ncurses \
    php7 php7-fpm \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-gd \
    php7-iconv \
    php7-json \
    php7-mcrypt \
    php7-mbstring \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_sqlite \
    php7-phar \
    php7-session \
    php7-simplexml \
    php7-tokenizer \
    php7-xml \
    php7-xmlwriter \
    php7-mysqlnd \
    php7-zlib \
    php7-xdebug \
    build-base \
    wget \
    vim \
    composer \
#  	docker \
#   openrc \
  && rm -rf /var/cache/apk/* \
  && mkdir /tmp/nginx \
  && sed -i 's/memory_limit = .*/memory_limit = 768M/' /etc/php7/php.ini \
  && sed -i 's/post_max_size = .*/post_max_size = 50M/' /etc/php7/php.ini \
  && echo 'sendmail_path = "/bin/true"' >> /etc/php7/php.ini \
  && echo 'date.timezone = "America/New_York"' >> /etc/php7/php.ini \
  && sed -i '/^user/c \user = nginx' /etc/php7/php-fpm.conf \
  && sed -i '/^group/c \group = nginx' /etc/php7/php-fpm.conf \
  && sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php7/php-fpm.conf

# Comment this line if we want to share the docker bus between containers.
#RUN rc-update add docker boot

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Fancy prompt.
RUN echo "COLOR=2; if [ \$SITE_ROLE == 'subscriber' ]; then COLOR=3; fi" >> /root/.bashrc
RUN echo "PS1=\"\[\$(tput setaf \$COLOR)\$(tput bold)[\]chf@\\h$:\\w]#\[\$(tput sgr0) \]\"" >> /root/.bashrc

# Configure PHP-FPM
RUN mkdir /etc/php7/custom.d
COPY config/00_xdebug.conf /etc/php7/custom.d/00_xdebug.ini
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /var/www/html
# Copy Site scripts into the container.
COPY scripts/*.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]