if [ ${ENVIRONMENT} = "testing" ]; then 
    echo "test"
    cp -r /app/* /var/www/
    cp /etc/app/config.dev /var/www/config
    php-fpm --fpm-config /etc/php-fpm.conf
else
    echo "prod"
    cp -r /app/* /var/www/
    cp /etc/app/config.prod /var/www/config
    php-fpm --fpm-config /etc/php-fpm.conf
fi