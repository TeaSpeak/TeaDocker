# This is the official TeaSpeak docker repository
This repository holds all Dockerfiles and bash scripts to build the TeaSpeak Server Images as well as the Web-Client Image

## Table of Content
1. [Server Images](#server-images)
    1. [Build and Run - Alpine Flavoured](#alpine-179mb-16-layers)
    2. [Build and Run - Debian Flavoured](#debian-427mb-14-layers)
    3. [Build and Run - Ubuntu Flavoured](#ubuntu-431mb-17-layers)
    6. [EnvVars and Build-Args](#envvars-and-build-args-server)
    4. [Run the Server via `docker-compose`](#run-the-server-via-docker-compose)
    5. [View the Logs and get the Token](#view-the-logs-and-token)
2. [Web Image](#web-image)
    1. [Build and Run - Alpine Flavoured](#alpine-413mb-21-layers)
    2. [Files and Volumes](#files-and-volumes)
    3. [EnvVars and Build-Args](#envvars-and-build-args-web)
    4. [Host the WebClient via `docker-compose`](#host-the-web-client-via-docker-compose)
    5. [Ideas for the Future](#ideas-to-improve-the-web-client-image)

## Server images
Basic instructions to build and run the TeaSpeak server images yourself.

#### Alpine (~179MB, 16 Layers)
```shell script
# Build the Image with the latest server
docker build -f server/alpine.Dockerfile -t teaspeak/server:latest-alpine ./server

# alternatively with server version <x.y.z>
# docker build -f server/alpine.Dockerfile --build-arg SERVER_VERSION=<x.y.z> -t teaspeak/server:<x.y.z>-alpine ./server

# run the Alpine based server image
docker run -d \
  -v teaspeak_logs:/ts/logs \
  -v teaspeak_db:/ts/database \
  -v teaspeak_files:/ts/files \
  -v teaspeak_certs:/ts/certs \
  -v teaspeak_config:/ts/config \
  -v teaspeak_crash_dumps:/ts/crash_dumps \
  -p 9987:9987/tcp -p 9987:9987/udp -p 10101:10101/tcp -p 30303:30303/tcp \
  --restart=unless-stopped --name teaspeak-server teaspeak/server:latest-alpine
```

#### Debian (~427MB, 14 Layers)
<details>
    <summary>Build and Run Debian</summary>
  
```shell script
# Build the Image with the latest server
docker build -f server/debian.Dockerfile -t teaspeak/server:latest-debian ./server

# alternatively with server version <x.y.z>
# docker build -f server/debian.Dockerfile --build-arg SERVER_VERSION=<x.y.z> -t teaspeak/server:<x.y.z>-debian ./server

# run the Debian based server image
docker run -d \
  -v teaspeak_logs:/ts/logs \
  -v teaspeak_db:/ts/database \
  -v teaspeak_files:/ts/files \
  -v teaspeak_certs:/ts/certs \
  -v teaspeak_config:/ts/config \
  -v teaspeak_crash_dumps:/ts/crash_dumps \
  -p 9987:9987/tcp -p 9987:9987/udp -p 10101:10101/tcp -p 30303:30303/tcp \
  --restart=unless-stopped --name teaspeak-server teaspeak/server:latest-debian
```
</details>

#### Ubuntu (~431MB, 17 Layers)
<details>
    <summary>Build and Run Debian</summary>
    
```shell script
# Build the Image with the latest server
docker build -f server/ubuntu.Dockerfile -t teaspeak/server:latest-ubuntu ./server

# alternatively with server version <x.y.z>
# docker build -f server/ubuntu.Dockerfile --build-arg SERVER_VERSION=<x.y.z> -t teaspeak/server:<x.y.z>-ubuntu ./server

# run the Ubuntu based server image
docker run -d \
  -v teaspeak_logs:/ts/logs \
  -v teaspeak_db:/ts/database \
  -v teaspeak_files:/ts/files \
  -v teaspeak_certs:/ts/certs \
  -v teaspeak_config:/ts/config \
  -v teaspeak_crash_dumps:/ts/crash_dumps \
  -p 9987:9987/tcp -p 9987:9987/udp -p 10101:10101/tcp -p 30303:30303/tcp \
  --restart=unless-stopped --name teaspeak-server teaspeak/server:latest-ubuntu
```
</details>

### EnvVars and Build-args (server)

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

### Run the server via docker-compose
<details>
    <summary>docker-compose.yml</summary>
    
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
      - type: volume
        source: teaspeak_crash_dumps
        target: /ts/crash_dumps
    restart: unless-stopped

volumes:
  teaspeak_certs:
  teaspeak_crash_dumps:
  teaspeak_config:
  teaspeak_db:
  teaspeak_files:
  teaspeak_logs:
```
</details>

To run this please ensure you have docker-compose [installed](https://docs.docker.com/compose/install/).
```shell script
docker-compose up -d
```

### View the Logs and Token
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


## Web Image

Basic instructions to build and host the TeaWeb client images yourself.

### Alpine (~41.3MB, 21 Layers)
This image is based on the official Nginx Docker image (Alpine Linux flavour)
```shell script
# Build the image with the latest web release
docker build -f web/Dockerfile -t teaspeak/web:latest ./web

# alternatively with a specific web version <gitHash>
# docker build -f web/Dockerfile --build-arg WEB_VERSION=<gitHash> -t teaspeak/web:<gitHash> ./web

# run the Ubuntu based server image
docker run -d \
  -p 80:80 -p 443:443 \
  -v $(pwd)/certs:/etc/ssl/certs \
  --restart=on-failure:3 --name teaspeak-web teaspeak/web:latest
```

### Files and Volumes

This image will auto-generate a self-signed certificate at initial boot-up, 
unless the user provides one during from the get-go.
This happens because an https connection is ***required*** by the web client to function.
Should the user decide to provide their own certificates at initial boot or later, 
then the following aspects have to be kept in mind:

* the certificate and key have to have a name in these formats:
  * the crt file: `tea_bundle.crt`
  * the key file: `tea.key`
* optionally the user can also provide a Diffie–Hellman parameter, 
otherwise the file will also be generated at initial boot
  * the Diffie–Hellman param: `dhparam.pem`
 
All auto-generated files will be persisted in the `/etc/ssl/certs`  folder within the container.
This folder, if not mounted by the user, will be force mounted into an anonym volume on the host machine.
By using the above `docker run` command, or the provided `docker-compose` script for the web client a bind-mounted
folder shall be used to store the `.crt`, `.key` and `.pem` files.

### EnvVars and Build-args (web)

| Variable | Default | Description |
|:--------:|:-------:|:-----------:|
|  **TZ**  | `Europe/Berlin` | Sets the timezone within the container. |

| Build-Arg | Default | Description |
|:---------:|:-------:|:-----------:|
| **TEASPEAK_VERSION** | `9a23f96` | This build argument sets the web client version to be installed in the resulting image |

### Host the web client via docker-compose
<details>
    <summary>docker-compose.yml</summary>

```yaml
version: '3.7'
services:
  teaspeak-server:
    image: teaspeak/web:latest
    environment:
      - TZ=Europe/Amsterdam
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - type: bind
        source: ./certs
        target: /etc/ssl/certs
    restart: on-failure:3
```
</details>

To run this please ensure you have docker-compose [installed](https://docs.docker.com/compose/install/).
```shell script
docker-compose up -d
```

### Ideas to improve the web client image

*Note:* The list below is not sorted by any priority, nor are there concrete plans to realize the listed ideas.
The following should not be misunderstood as planned features, but more ideas remaining from the image rework.

* allow the user to change the cert- and key-file name via env
* allow the user to use let's encrypt to provide certificates (**REQUIRES** user to have a valid TLD)
* Have an idea not listed here? Open an [issue](https://github.com/TeaSpeak/TeaDocker/issues) and we shall discuss!