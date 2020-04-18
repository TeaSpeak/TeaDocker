FROM frolvlad/alpine-glibc:latest

LABEL varion="1.0" \
    maintainer="h1dden-da3m0n" \
    description="A simple TeaSpeak server running on alpine-glibc (amd64)"

ARG TEASPEAK_VERSION="1.4.12"

RUN	apk update --no-cache && apk upgrade --no-cache \
    && apk add --no-cache \
         bash ca-certificates wget curl python libnice ffmpeg tzdata \
    \
    && mkdir ts && cd /ts \
    && wget -nv -O TeaSpeak.tar.gz https://repo.teaspeak.de/server/linux/amd64/TeaSpeak-$TEASPEAK_VERSION.tar.gz \
    && tar -xzf TeaSpeak.tar.gz \
    && rm TeaSpeak.tar.gz \
    && curl -sLS https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl \
    && chmod a+rx /usr/local/bin/youtube-dl

WORKDIR /ts

EXPOSE 9987/udp 10101 30303

VOLUME ["/ts/logs", "/ts/certs", "/ts/files", "/ts/database"]

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/ts/libs/" \
    LD_PRELOAD="/ts/libs/libjemalloc.so.2" \
    TEASPEAK_VERSION="${TEASPEAK_VERSION}" \
    TZ="Europe/Berlin"

ENTRYPOINT ["./TeaSpeakServer"]

CMD ["-Pgeneral.database.url=sqlite://database/TeaData.sqlite"]