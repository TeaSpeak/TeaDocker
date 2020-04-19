# This is the official TeaSpeak docker repository
This repository holds all Dockerfiles and bash scripts to build the TeaSpeak Server Images and Web-Client Image

## Server images
Basic instructions to build and run the TeaSpeak server images yourself.

### Alpine (~183MB, 13 Layers)
```shell script
# Build the Image with the server version 1.4.12 (default)
docker build -f server/alpine.Dockerfile -t teaspeak/server:1.4.12-alpine .

# alternatively with server version x.y.z
# docker build -f server/alpine.Dockerfile --build-arg TEASPEAK_VERSION=x.y.z -t teaspeak/server:x.y.z-alpine .

# run the Alpine based server image
docker run -d \
  -v teaspeak_logs:/ts/logs \
  -v teaspeak_db:/ts/database \
  -v teaspeak_files:/ts/files \
  -v teaspeak_certs:/ts/certs \
  -v teaspeak_config:/ts/config \
  -p 9987:9987 -p 10101:10101/tcp -p 30303:30303/tcp \
  --restart=unless-stopped --name teaspeak-server teaspeak/server:1.4.12-alpine
```

### Debian (~445MB, 11 Layers)
```shell script
# Build the Image with the server version 1.4.12 (default)
docker build -f server/debian.Dockerfile -t teaspeak/server:1.4.12-debian .

# alternatively with server version x.y.z
# docker build -f server/debian.Dockerfile --build-arg TEASPEAK_VERSION=x.y.z -t teaspeak/server:x.y.z-debian .

# run the Debian based server image
docker run -d \
  -v teaspeak_logs:/ts/logs \
  -v teaspeak_db:/ts/database \
  -v teaspeak_files:/ts/files \
  -v teaspeak_certs:/ts/certs \
  -v teaspeak_config:/ts/config \
  -p 9987:9987 -p 10101:10101/tcp -p 30303:30303/tcp \
  --restart=unless-stopped --name teaspeak-server teaspeak/server:1.4.12-debian
```

### Ubuntu (~437MB, 14 Layers)
```shell script
# Build the Image with the server version 1.4.12 (default)
docker build -f server/ubuntu.Dockerfile -t teaspeak/server:1.4.12-ubuntu .

# alternatively with server version x.y.z
# docker build -f server/ubuntu.Dockerfile --build-arg TEASPEAK_VERSION=x.y.z -t teaspeak/server:x.y.z-ubuntu .

# run the Ubuntu based server image
docker run -d \
  -v teaspeak_logs:/ts/logs \
  -v teaspeak_db:/ts/database \
  -v teaspeak_files:/ts/files \
  -v teaspeak_certs:/ts/certs \
  -v teaspeak_config:/ts/config \
  -p 9987:9987 -p 10101:10101/tcp -p 30303:30303/tcp \
  --restart=unless-stopped --name teaspeak-server teaspeak/server:1.4.12-ubuntu
```

## Run the server via docker-compose
docker-compose.yml
```yaml
version: '3.7'
services:
  teaspeak-server:
    image: teaspeak/server:latest
    environment:
      - TZ=Europe/Amsterdam
    ports:
      - "9987:9987"
      - "10101:10101/tcp"
      - "30303:30303/tcp"
    volumes:
      - type: volume
        source: teaspeak_certs
        target: /ts/certs
      - type: volume
        source: teaspeak_config
        target: /ts/config
      - type: volume
        source: teaspeak_db
        target: /ts/database
      - type: volume
        source: teaspeak_files
        target: /ts/files
      - type: volume
        source: teaspeak_logs
        target: /ts/logs
    restart: unless-stopped

volumes:
  teaspeak_certs:
  teaspeak_config:
  teaspeak_db:
  teaspeak_files:
  teaspeak_logs:
```

To run this please ensure you have docker-compose [installed](https://docs.docker.com/compose/install/).
```shell script
docker-compose up -d
```

## Logs and Token
To view the docker container logs and to find the server token you have to run the following command:
```shell script
docker logs <container-name|container-id>

# to get the container name or id run the following
docker ps 

# eg. if the server gets started as displayed in the above section
docker logs teaspeak-server

# and if you want to follow the logs (ctrl+c to stop following)
docker logs -f teaspeak-server
```

## Env and Build-args

| Variable | Default | Description |
|:--------:|:-------:|:-----------:|
|  **TZ**  | `Europe/Berlin` | Sets the timezone within the container. |

The `TZ` variable works everywhere **EXCEPT** in the `alpine` based server image, where the log times are UTC.
This seems to be a bug with the glib based Alpine Linux image.

(their [Wiki](https://wiki.alpinelinux.org/wiki/Setting_the_timezone) explicitly states that glibc based installs define their timezones differently, yet fail to mention how to set it in that case :confused: :unamused:)

| Build-Arg | Default | Description |
|:---------:|:-------:|:-----------:|
| **TEASPEAK_VERSION** | `1.4.12` | This build argument sets the server version to be installed in the resulting image |
|  **uid**  | `4242`  | The default user id of the `teaspeak` user used in the container |
|  **gid**  | `4242`  | The default group id of the `teaspeak` user used in the container |


## Web Image
All references to build the TeaSpeak Web client in a Docker container

### Web build docker
Build the web docker
```
docker build --tag teaweb:build web/build/
```

Execute the build script and build the newest version
```
docker run --rm -v /tmp/build/logs/:/build/logs/ -v /tmp/build/packages/:/build/packages/ teaweb:build --enable-release --enable-debug
```
If the build succeed you should find the final packages within `/tmp/build/packages/`.  
A complete build log could then be found here `/tmp/build/logs/`