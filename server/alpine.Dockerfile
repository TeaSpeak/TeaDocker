FROM frolvlad/alpine-glibc:latest

LABEL varion="1.0" \
    maintainer="h1dden-da3m0n" \
    description="A simple TeaSpeak server running on alpine-glibc (amd64_stable)"

ARG uid=4242
ARG gid=4242
ARG TEASPEAK_VERSION="1.4.12"

RUN	apk update --no-cache && apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates wget python ffmpeg tzdata \
    \
    && mkdir /ts /ts/logs /ts/certs /ts/files /ts/database /ts/config \
    && wget -nv -O /ts/TeaSpeak.tar.gz https://repo.teaspeak.de/server/linux/amd64_stable/TeaSpeak-$TEASPEAK_VERSION.tar.gz \
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
    && apk del wget

WORKDIR /ts

EXPOSE 9987 10101/tcp 30303/tcp

VOLUME ["/ts/logs", "/ts/certs", "/ts/config", "/ts/files", "/ts/database"]

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/ts/libs/" \
    TEASPEAK_VERSION="${TEASPEAK_VERSION}" \
    TZ="Europe/Berlin"

USER teaspeak

ENTRYPOINT ["./TeaSpeakServer"]

CMD ["-Pgeneral.database.url=sqlite://database/TeaData.sqlite"]