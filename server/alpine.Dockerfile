FROM frolvlad/alpine-glibc:latest

LABEL varion="1.0" \
    maintainer="Markus Hadenfeldt <docker@teaspeak.de>, h1dden-da3m0n" \
    description="A simple TeaSpeak server running on alpine-glibc (amd64_stable)"

ARG uid=4242
ARG gid=4242
ARG SERVER_VERSION

RUN	apk update --no-cache && apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates curl python ffmpeg tzdata \
    \
    && mkdir -p /ts /ts/logs /ts/certs /ts/files /ts/database /ts/config /ts/crash_dumps \
    && SERVER_VERSION=${SERVER_VERSION:-$(curl -s https://repo.teaspeak.de/server/linux/amd64_stable/latest)} \
    && wget -nv -O /ts/TeaSpeak.tar.gz \
        https://repo.teaspeak.de/server/linux/amd64_stable/TeaSpeak-$SERVER_VERSION.tar.gz \
    && tar -xzf /ts/TeaSpeak.tar.gz -C /ts \
    && rm /ts/TeaSpeak.tar.gz \
    && echo "" > /ts/config/config.yml && ln -sf /ts/config/config.yml /ts/config.yml \
    && wget -nv -O /usr/local/bin/youtube-dl https://yt-dl.org/downloads/latest/youtube-dl \
    && chmod a+rx /usr/local/bin/youtube-dl \
    \
    && addgroup -g ${gid} teaspeak \
    && adduser -H -u ${uid} -G teaspeak -D teaspeak \
    && chown -R ${uid}:${gid} /ts \
    \
    && apk del curl

WORKDIR /ts

EXPOSE 9987 10101/tcp 30303/tcp

VOLUME ["/ts/logs", "/ts/certs", "/ts/config", "/ts/files", "/ts/database", "/ts/crash_dumps"]

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/ts/libs/" \
    SERVER_VERSION="${SERVER_VERSION}" \
    TZ="Europe/Berlin"

USER teaspeak

ENTRYPOINT ["./TeaSpeakServer"]

CMD ["-Pgeneral.database.url=sqlite://database/TeaData.sqlite"]