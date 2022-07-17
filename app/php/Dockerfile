FROM php:fpm

ENV ENVIRONMENT=testing

COPY etc/config* /etc/app/
COPY etc/fpm /etc/php-fpm.conf
# Install script for application
COPY --chown=www-data:www-data www /app
COPY install.sh /usr/local/bin/install.sh
RUN chmod +x /usr/local/bin/install.sh \
     && chown www-data:www-data /var/www

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT install.sh

# Change current user to www
USER root


# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]