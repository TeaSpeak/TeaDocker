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
    6. [Where to store data](#where-to-store-data)
2. [Web Image](#web-image)
    1. [Build and Run - Alpine Flavoured](#web-alpine-flavour)
    2. [Files and Volumes](#files-and-volumes)
    3. [EnvVars and Build-Args](#envvars-and-build-args-web)
    4. [Host the WebClient via `docker-compose`](#host-the-web-client-via-docker-compose)
3. [Updating](#updating)
    1. [Updating with `docker run`](#for-docker-run-started-serverwebclients)
    2. [Updating with `docker-compose`](#for-docker-compose-started-serverwebclients)
    3. [Cleanup `docker` Images](#cleanup)
4. [Ideas for future improvements](#ideas-for-future-improvements)
    1. [Server Ideas](#server-ideas)
    2. [WebClient Ideas](#webclient-ideas)

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
|:--------:|:-------:|:----------- |
|  **TZ**  | `Europe/Berlin` | Sets the timezone within the container. |

The `TZ` variable works everywhere **EXCEPT** in the `alpine` based server image, where the log times are UTC.
This seems to be a bug with the glib based Alpine Linux image.

(their [Wiki](https://wiki.alpinelinux.org/wiki/Setting_the_timezone) explicitly states that glibc based installs define their timezones differently, yet fail to mention how to set it in that case :confused: :unamused:)

| Build-Arg | Default | Description |
|:---------:|:-------:|:----------- |
| **SERVER_VERSION** | *blank* | This build argument sets the server version to be installed in the resulting image. If its left *blank* the latest released server verison will be installed. |
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
      - "9987:9987/udp"
      - "9987:9987/tcp"
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

### Where to Store Data

Important note: There are several ways to store data used by applications that run in Docker containers.
We encourage users of the `teaspeak` images to familiarize themselves with the options available, including:

- Let Docker manage the storage of your database data [by writing the database files to disk on the host system using its own internal volume management](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume).
This is the default and is easy and fairly transparent to the user. 
The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.
- Create a data directory on the host system (outside the container) and [mount this to a directory visible from inside the container](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume). 
This places the database files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. 
The downside is that the user needs to make sure that the directory exists, and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area.

## Web Image

[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/teaspeak/web/latest?label=Release&style=for-the-badge)](https://github.com/TeaSpeak/TeaWeb/releases)
[![Docker Image Version (tag latest beta semver)](https://img.shields.io/docker/v/teaspeak/web/beta?label=Development&color=orange&style=for-the-badge)](https://github.com/TeaSpeak/TeaWeb/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/teaspeak/web?style=for-the-badge)](https://hub.docker.com/r/teaspeak/web)
[![Official Image](https://img.shields.io/badge/Dockerhub-official-blue?style=for-the-badge)](https://hub.docker.com/r/teaspeak/web)

Basic instructions to build and host the TeaWeb client images yourself.

### Web Alpine Flavour 

[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/teaspeak/web?style=for-the-badge)](https://microbadger.com/images/teaspeak/web)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/teaspeak/web?style=for-the-badge)](https://microbadger.com/images/teaspeak/web)

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
|:--------:|:-------:|:----------- |
|  **TZ**  | `Europe/Berlin` | Sets the timezone within the container. |

| Build-Arg | Default | Description |
|:---------:|:-------:|:----------- |
| **WEB_VERSION** | *blank* | This build argument sets the web client version to be installed in the resulting image. If its left *blank* the latest released client version will be installed |
### Host the web client via docker-compose
<details>
    <summary>docker-compose.yml</summary>

```yaml
version: '3.7'
services:
  teaspeak-web:
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

## Updating

If you never updated a container bases application before you can follow these simplified workflows:

### For `docker run` started Server/WebClients

1. Notify the user base of the application about an upcoming update maintenance 
(best to specify a specific date/time and choose a relatively quiet timeslot)
2. Before the maintenance starts download the image version you want to update to, 
for this example we assume an upgrade from previous `latest` to new `latest`, 
by issuing a `docker pull teaspeak/[server|web]:latest` command. 
(*NOTE:* this will clone the new version of the image locally, so it can be used once you restart to update)
3. Give one last heads up to the users that may be still using the application and then run 
`docker stop teaspeak-[server|web]` to shut down the application, after that run `docker rm teaspeak-[server|web]`
to remove the old version container.
4. As soon as the commands of step `3.` return successfully you can restart the application with the new 
image versions by running the corresponding run commands found in the [Server](#server-images) or [Web](#web-image) sections.

### For `docker-compose` started Server/WebClients

1. Notify the user base of the application about an upcoming update maintenance 
(best to specify a specific date/time and choose a relatively quiet timeslot)
2. If you are using a specific `tag` for the app images in your compose `yaml` files change it to the tag you want to update to.
Then use `docker-compose pull` to pull the latest version of your desired image specified in the `docker-compose.yml`.
(*NOTE:* this will clone the new version of the image locally, so it can be used once you restart to update)
3. Give one last heads up to the users that may be still using the application and then issue the following two commands:
`docker-compose down` and `docker-compose up -d`
4. As soon as the commands of step `3.` return successfully you can start reconnecting to the applications.

### Cleanup

To clean up old unused images you can either delete them manually by
* first listing them with `docker images`, finding the no longer used images and the running `docker rmi <image-name...>`
* or by running `docker image prune`, yet be careful with this command, 
as it will delete **ALL** images not used by any container and could yield unwanted results therefor

## Ideas for Future Improvements

*Note:* The list below is not sorted by any priority, nor are there concrete plans to realize the listed ideas.
The following should not be misunderstood as planned features, but more ideas remaining from the image rework.

### Server Ideas
* use single volume mount point to decrease CLI clutter (requires the server to handle symlinks better)

### WebClient Ideas
* allow the user to change the cert- and key-file name via env
* allow the user to use let's encrypt to provide certificates (**REQUIRES** user to have a valid TLD)
 
Have an idea not listed here? Open an [issue](https://github.com/TeaSpeak/TeaDocker/issues) and we shall discuss!