FROM debian:10-slim

LABEL varion="2.0" \
    maintainer="ESh4d0w, Markus Hadenfeldt <docker@teaspeak.de>, h1dden-da3m0n" \
    description="A simple TeaSpeak server running on debian 10 (amd64_stable)"

ARG uid=4242
ARG gid=4242
ARG SERVER_VERSION

RUN	apt-get update && apt-get upgrade -qqy \
    && apt-get install --no-install-recommends -qqy \
         ca-certificates wget curl python ffmpeg tzdata \
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
    && groupadd -g ${gid} teaspeak \
    && useradd -M -u ${uid} -g ${gid} teaspeak \
    && chown -R ${uid}:${gid} /ts \
    \
    && apt-get purge -y wget curl \
    && apt-get clean autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ts

EXPOSE 9987/tcp 9987/udp 10101/tcp 30303/tcp

VOLUME ["/ts/logs", "/ts/certs", "/ts/config", "/ts/files", "/ts/database", "/ts/crash_dumps"]

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/ts/libs/" \
    LD_PRELOAD="/ts/libs/libjemalloc.so.2" \
    SERVER_VERSION="${SERVER_VERSION}" \
    TZ="Europe/Berlin"

USER teaspeak

ENTRYPOINT ["./TeaSpeakServer"]

CMD ["-Pgeneral.database.url=sqlite://database/TeaData.sqlite"]