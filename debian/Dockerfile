FROM debian:jessie

MAINTAINER Markus Hadenfeldt, docker@teaspeak.de

LABEL version="1.0"
LABEL description="A simple TeaSpeak server running on debian (amd64)"

RUN apt-get update; apt-get upgrade; apt-get -y install
RUN apt-get install -y curl wget tar libnice10
RUN 																		\
	mkdir -p /opt/teaspeak;															\
	cd /opt/teaspeak; 															\
	LATEST_VERSION=$(curl -k https://repo.teaspeak.de/latest);										\
	wget -O TeaSpeak.tar.gz https://repo.teaspeak.de/server/linux/amd64/TeaSpeak-${LATEST_VERSION}.tar.gz; 					\
	tar xvf TeaSpeak.tar.gz; 														\
	rm TeaSpeak.tar.gz;

ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/opt/teaspeak/libs/"
ENV PATH "${PATH}:/opt/teaspeak"
EXPOSE 9987/udp 10101 30303
WORKDIR /opt/teaspeak

COPY ./entrypoint.sh /opt/teaspeak/
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "TeaSpeakServer" ]
