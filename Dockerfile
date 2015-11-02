FROM debian

ENV APT_PROXY http://192.168.1.10:3128

RUN \
  echo "\n\
Acquire::HTTP::Proxy \"$APT_PROXY\";\n\
Acquire::HTTPS::Proxy \"$APT_PROXY\";\n\
" > /etc/apt/apt.conf.d/01proxy && \
 echo " \n\
deb http://kambing.ui.ac.id/debian/ jessie main\n\
deb http://kambing.ui.ac.id/debian/ jessie-updates main\n\
deb http://kambing.ui.ac.id/debian-security/ jessie/updates main\n\
" > /etc/apt/sources.list && \
# apt-get -o Acquire::Check-Valid-Until=false update -y
apt-get update -y

RUN apt-get install \
  supervisor \
  php5-cli \
  php5-fpm \
  nginx \
#  curl \
#  php5-mcrypt \
  -y

# RUN apt-get install vim net-tools -y

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY toran /toran
COPY toran.sh /toran.sh
COPY config/auth.json /toran/auth.json
COPY config/toran-http.conf /etc/nginx/sites-enabled/toran-http.conf

RUN \
  rm -f /etc/nginx/sites-enabled/default && \
  usermod -u 1000 www-data && \
  groupmod -g 1000 www-data && \
  mkdir /toran-data && \
  chown -R www-data:www-data /toran && \
  chown -R www-data:www-data /toran-data && \
  echo "daemon off;" >> /etc/nginx/nginx.conf && \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

ENV TORAN_SECRET qwertyuiop1234567890
ENV TORAN_SCHEME http
ENV TORAN_HTTP_PORT 8000
ENV TORAN_HTTPS_PORT 443
ENV TORAN_HOST localhost
ENV TORAN_BASE_URL ""
ENV TORAN_TOKEN_GITHUB f1881817f25b69a8dc9af80329fb1b5dc6197786

ENV TORAN_PHP_TIMEZONE Asia\\/Jakarta

WORKDIR /toran

ENTRYPOINT ["/toran.sh"]
CMD ["/usr/bin/supervisord"]