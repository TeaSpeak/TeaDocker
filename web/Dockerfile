FROM nginx:alpine

LABEL varion="1.0" \
    maintainer="h1dden-da3m0n" \
    description="A simple TeaSpeak WebClinet running on Nginx-Alpine"

ARG WEB_VERSION="9a23f96"

ENV WEB_VERSION="${WEB_VERSION}" \
    TZ="Europe/Berlin"

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./entrypoint.sh /

RUN apk update --no-cache && apk upgrade --no-cache \
    && apk add --no-cache openssl tzdata \
    \
    && mkdir -p /var/www/TeaWeb /etc/ssl/certs \
    && wget -nv -O /var/www/TeaWeb/TeaWeb-release.zip \
        https://github.com/TeaSpeak/TeaWeb/releases/download/${WEB_VERSION}/TeaWeb-release.zip \
    && unzip -oq /var/www/TeaWeb/TeaWeb-release.zip -d /var/www/TeaWeb \
    && rm //var/www/TeaWeb/TeaWeb-release.zip \
    && sed -i /etc/nginx/mime.types \
        -e 's/}/    application\/wasm    wasm;\n}/' \
    && chmod +x /entrypoint.sh

VOLUME ["/etc/ssl/certs"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]