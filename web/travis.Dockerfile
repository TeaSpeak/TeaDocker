FROM nginx:alpine

# ONYL FOR BUILD AUTOMATION USE OR IF YOU KNOW WHAT YOU ARE DONG!
LABEL version="1.0" \
    maintainer="Markus Hadenfeldt <docker@teaspeak.de>, h1dden-da3m0n" \
    description="A simple TeaSpeak WebClient running on Nginx-Alpine"

ARG WEB_ZIP="TeaWeb-release.zip"
ARG WEB_VERSION

COPY ./${WEB_ZIP} /var/www/TeaWeb/
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./entrypoint.sh /

RUN apk update --no-cache && apk upgrade --no-cache \
    && apk add --no-cache openssl tzdata \
    \
    && mkdir -p /var/www/TeaWeb /etc/ssl/certs \
    && unzip -oq /var/www/TeaWeb/TeaWeb-*.zip -d /var/www/TeaWeb \
    && rm /var/www/TeaWeb/TeaWeb-*.zip \
    && sed -i /etc/nginx/mime.types -e 's/}/    application\/wasm    wasm;\n}/' \
    && chmod +x /entrypoint.sh

ENV WEB_VERSION="${WEB_VERSION}" \
    TZ="Europe/Berlin"

VOLUME ["/etc/ssl/certs"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]