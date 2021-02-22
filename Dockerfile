ARG DRUPAL_BASE_IMAGE=drupal:8-apache

# PHP Dependency install via Composer.
FROM composer as vendor

COPY composer.json composer.json
COPY composer.lock composer.lock
COPY web/ web/

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-dev \
    --prefer-dist

# Build the Docker image for Drupal.
FROM $DRUPAL_BASE_IMAGE

ENV DRUPAL_VERSION=8

# Copy precompiled codebase into the container.
COPY --from=vendor /app/ /var/www/html/

# Copy other required configuration into the container.
# COPY config/ /var/www/html/config/
# COPY load.environment.php /var/www/html/load.environment.php

# Make sure file ownership is correct on the document root.
RUN chown -R www-data:www-data /var/www/html/web

# Add Drush Launcher.
RUN curl -OL https://github.com/drush-ops/drush-launcher/releases/download/0.8.0/drush.phar \
 && chmod +x drush.phar \
 && mv drush.phar /usr/local/bin/drush

# Adjust the Apache docroot.
ENV APACHE_DOCUMENT_ROOT=/var/www/html/web

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]