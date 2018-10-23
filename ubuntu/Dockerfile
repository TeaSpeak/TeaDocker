FROM ubuntu:latest

MAINTAINER ESh4d0w

LABEL version="1.0"
LABEL description="A simple TeaSpeak server running on ubuntu (amd64)"

RUN	mkdir ts
RUN	apt update
RUN	apt upgrade -y
RUN	apt install wget curl libnice10 python-pip ffmpeg -y
RUN	cd /ts &&\
	wget -O TeaSpeak.tar.gz https://repo.teaspeak.de/server/linux/amd64/TeaSpeak-$(curl -k https://repo.teaspeak.de/server/linux/amd64/latest).tar.gz &&\
	tar -xzf TeaSpeak.tar.gz &&\
	rm TeaSpeak.tar.gz
RUN curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
RUN	chmod a+rx /usr/local/bin/youtube-dl

WORKDIR /ts

EXPOSE 9987/udp 10101 30303

VOLUME ["/ts/logs", "/ts/certs", "/ts/files", "/ts/database"]

ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/ts/libs/"
ENC LD_PRELOAD "/ts/libs/libjemalloc.so.2"

ENTRYPOINT ["./TeaSpeakServer"]

CMD ["-Pgeneral.database_url=sqlite://database/TeaData.sqlite"]