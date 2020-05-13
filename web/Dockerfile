FROM nginx:alpine

LABEL version="1.0" \
    maintainer="Markus Hadenfeldt <docker@teaspeak.de>, h1dden-da3m0n" \
    description="A simple TeaSpeak WebClient running on Nginx-Alpine"

ARG WEB_VERSION

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./entrypoint.sh /

RUN apk update --no-cache && apk upgrade --no-cache \
    && apk add --no-cache openssl tzdata curl jq \
    \
    && mkdir -p /var/www/TeaWeb /etc/ssl/certs \
    && WEB_VERSION=${WEB_VERSION:-$(curl -s https://api.github.com/repos/TeaSpeak/TeaWeb/releases/latest | jq -r '.tag_name')} \
    && wget -q -O /var/www/TeaWeb/TeaWeb-release.zip \
        https://github.com/TeaSpeak/TeaWeb/releases/download/${WEB_VERSION}/TeaWeb-release.zip \
    && unzip -oq /var/www/TeaWeb/TeaWeb-release.zip -d /var/www/TeaWeb \
    && rm /var/www/TeaWeb/TeaWeb-release.zip \
    && sed -i /etc/nginx/mime.types -e 's/}/    application\/wasm    wasm;\n}/' \
    && chmod +x /entrypoint.sh \
    \
    && apk del --no-cache curl jq

ENV WEB_VERSION="${WEB_VERSION:-latest-$(date +%d%m%y)}" \
    TZ="Europe/Berlin"

VOLUME ["/etc/ssl/certs"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]