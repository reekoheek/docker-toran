#!/bin/bash

set -e

if [ "$1" = "/usr/bin/supervisord" ]; then
  echo "
parameters:
    secret:           $TORAN_SECRET
    toran_scheme:     $TORAN_SCHEME
    toran_http_port:  $TORAN_HTTP_PORT
    toran_https_port: $TORAN_HTTPS_PORT
    toran_host:       $TORAN_HOST
    toran_base_url:   $TORAN_BASE_URL
" > /toran/app/config/parameters.yml

  cat /toran/app/config/parameters.yml

  sed -i "s/;date\.timezone.*/date\.timezone = ${TORAN_PHP_TIMEZONE}/g" /etc/php5/cli/php.ini

  # ln -sf /toran-data/config.yml /toran/app/config/toran.yml
  ln -sf /toran-data/config.yml /toran/app/toran/config.yml

  mkdir -p /toran/app/toran/composer
  cp -f /toran/auth.json /toran/app/toran/composer/auth.json
  sed -i "s/\"github.com\":.*$/\"github.com\":\"$TORAN_TOKEN_GITHUB\"/g" /toran/app/toran/composer/auth.json

  ./bin/cron -v

  chown -R www-data:www-data /toran
fi

exec "$@"
