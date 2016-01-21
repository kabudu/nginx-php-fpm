# nginx-php-fpm Dockerfile

# Grab base image
FROM gliderlabs/alpine:3.3
MAINTAINER Kamba Abudu <hello@boxedcode.com>

# Install software requirements
RUN BUILD_PACKAGES="vim bash supervisor nginx php-fpm php-opcache php-curl php-intl php-mcrypt php-sqlite3 php-ctype php-json php-openssl php-dom php-cli" && \
apk-install $BUILD_PACKAGES

# Replace the default nginx.conf file
RUN rm -f /etc/nginx/nginx.conf
ADD ./nginx.conf /etc/nginx/nginx.conf

# tweak nginx config
RUN sed -i -e"s/worker_processes  1/worker_processes 5/" /etc/nginx/nginx.conf && \
sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
echo "daemon off;" >> /etc/nginx/nginx.conf

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/php.ini && \
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/php.ini && \
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/php.ini && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/php-fpm.conf && \
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/php-fpm.conf && \
sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php/php-fpm.conf && \
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php/php-fpm.conf && \
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php/php-fpm.conf && \
sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php/php-fpm.conf && \
sed -i -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" /etc/php/php-fpm.conf && \
sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" /etc/php/php-fpm.conf && \
sed -i -e "s/user = nobody/user = nginx/g" /etc/php/php-fpm.conf && \
sed -i -e "s/group = nobody/group = nginx/g" /etc/php/php-fpm.conf

# fix ownership of sock file for php-fpm
RUN sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php/php-fpm.conf && \
sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" /etc/php/php-fpm.conf && \
sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" /etc/php/php-fpm.conf

# nginx site conf
RUN rm -Rf /etc/nginx/conf.d/* && \
mkdir -p /etc/nginx/ssl/
ADD ./nginx-site-default.conf /etc/nginx/conf.d/default.conf

# Supervisor Config
ADD ./supervisord.conf /etc/supervisord.conf

# Entrypoint for triggering supervisord
ADD ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Setup Volume
VOLUME ["/usr/share/nginx/html"]
VOLUME ["/etc/nginx/ssl"]
VOLUME ["/var/log/nginx"]

# add test PHP file
ADD ./index.php /usr/share/nginx/html/index.php
RUN chown -Rf nginx.nginx /usr/share/nginx/html/

# Expose Ports
EXPOSE 443
EXPOSE 80

# Run entrypoint script
CMD ["/bin/bash", "/entrypoint.sh"]