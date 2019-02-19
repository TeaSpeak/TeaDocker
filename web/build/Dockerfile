FROM frolvlad/alpine-glibc:latest

MAINTAINER Markus Hadenfeldt <docker@teaspeak.de>

LABEL version="1.0"
LABEL description="A simple build docker which builds the web client"

#Install all required files
RUN apk update && apk upgrade && apk add --no-cache bash git python npm php cmake gcc make autoconf libtool automake musl-dev coreutils zip;

#Install emscrypten
RUN bash -c '                                           \
    if [[ ! -d build ]]; then                           \
        mkdir build;                                    \
    fi;                                                 \
    cd build;                                           \
    if [[ ! -d emsdk ]]; then                           \
        git clone https://github.com/juj/emsdk.git;     \
    fi;                                                 \
    cd emsdk;                                           \
    ./emsdk update-tags;                                \
    ./emsdk install latest;                             \
    if [[ $? -ne 0 ]]; then                             \
        echo "Failed to install emscripten";            \
        exit 1;                                         \
    fi;                                                 \
    ./emsdk activate latest;                            \
    if [[ $? -ne 0 ]]; then                             \
        echo "Failed to activate emscripten";           \
        exit 1;                                         \
    fi;                                                 \
    echo "source `pwd`/emsdk_env.sh" >> /etc/profile;   \
    echo "emscrypten successfully registered";          \
    cd ..;                                              \
    if [[ ! -d TeaWeb ]]; then                          \
        git clone https://github.com/TeaSpeak/TeaWeb;   \
    fi;';

VOLUME ["/build/logs", "/build/packages"]

COPY build_helper.sh /build/

ENTRYPOINT ["/build/build_helper.sh"]
CMD []