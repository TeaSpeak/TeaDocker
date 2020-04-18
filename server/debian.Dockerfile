FROM debian:10-slim

LABEL varion="2.0" \
    maintainer="ESh4d0w, Markus Hadenfeldt, docker@teaspeak.de, h1dden-da3m0n" \
    description="A simple TeaSpeak server running on debian 10 (amd64)"

ARG TEASPEAK_VERSION="1.4.12"

RUN	apt-get update && apt-get upgrade -qqy \
    && apt-get install --no-install-recommends -qqy \
         ca-certificates wget curl python libnice10 ffmpeg tzdata \
    \
    && mkdir ts && cd /ts \
    && wget -nv -O TeaSpeak.tar.gz https://repo.teaspeak.de/server/linux/amd64/TeaSpeak-$TEASPEAK_VERSION.tar.gz \
    && tar -xzf TeaSpeak.tar.gz \
    && rm TeaSpeak.tar.gz \
    && curl -sLS https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl \
    && chmod a+rx /usr/local/bin/youtube-dl \
    \
    && apt-get clean autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ts

EXPOSE 9987/udp 10101 30303

VOLUME ["/ts/logs", "/ts/certs", "/ts/files", "/ts/database"]

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/ts/libs/" \
    LD_PRELOAD="/ts/libs/libjemalloc.so.2" \
    TEASPEAK_VERSION="${TEASPEAK_VERSION}" \
    TZ="Europe/Berlin"

ENTRYPOINT ["./TeaSpeakServer"]

CMD ["-Pgeneral.database.url=sqlite://database/TeaData.sqlite"]