# Supported tags and respective `Dockerfile` links

- [`1.4-alpine`, `1.4.14-alpine`, `alpine`, `1.4`, `1.4.14`, `stable`](https://github.com/TeaSpeak/TeaDocker/blob/master/server/alpine.Dockerfile)
- [`1.4-debian`, `1.4.14-debian`, `debian`](https://github.com/TeaSpeak/TeaDocker/blob/master/server/debian.Dockerfile)
- [`1.4-ubuntu`, `1.4.14-ubuntu`, `ubuntu`](https://github.com/TeaSpeak/TeaDocker/blob/master/server/ubuntu.Dockerfile)

# Quick reference

- **Where to get help**:  
  [the TeaSpeak Forums](https://forum.teaspeak.de/) or [the TeaSpeak Community Server](https://web.teaspeak.de/?connect_default=1&connect_address=ts.TeaSpeak.de)

- **Where to file issues**:  
  [TeaDocker Issue Tracker](https://github.com/TeaSpeak/TeaDocker/issues)

- **Maintained by**:  
  TeaSpeak Developer [WolverinDEV](https://github.com/WolverinDEV) and volunteer [h1dden-da3m0n](https://github.com/h1dden-da3m0n)

- **Source of this description**:  
  [`TeaDocker/server` directory](https://github.com/TeaSpeak/TeaDocker/blob/master/server/readme.md) ([history](https://github.com/TeaSpeak/TeaDocker/commits/master/server/readme.md))

# What is TeaSpeak?
> TeaSpeak is a free to use client and server software for VoIP communication. It's the ideal deal software for everyone who is annoyed about limits and restrictions.

[TeaSpeak.de](https://teaspeak.de/)

![logo](https://img.teaspeak.de/teaspeak_logo_temp.png)

# How to use this image
To start a TeaSpeak server and map the ports to the host:

```console
$ docker run -d \
    -v teaspeak_logs:/ts/logs \
    -v teaspeak_db:/ts/database \
    -v teaspeak_files:/ts/files \
    -v teaspeak_certs:/ts/certs \
    -v teaspeak_config:/ts/config \
    -v teaspeak_crash_dumps:/ts/crash_dumps \
    -p 9987:9987/tcp -p 9987:9987/udp -p 10101:10101/tcp -p 30303:30303/tcp \
    --restart=unless-stopped --name teaspeak-server teaspeak/server
```

Then find the generated server query password and server admin privilege key using the following command:

```console
$ docker logs teaspeak-server
```

Please write both, the server query password and server admin privilege key, down.
These are needed to administrate the TeaSpeak server and should not get lost!

Finally, you can now connect to `localhost` in your TeaSpeak client or TeaSpeak Web-client.

## Container shell access

The `docker exec` command allows you to run commands inside a Docker container. The following command line will give you a shell inside your `teaspeak/server` container:

```console
$ docker exec -it teaspeak-server sh
```

The TeaSpeak server log is available through Docker's container log:

```console
$ docker logs teaspeak-server
# or to follow the logs
$ docker logs -f teaspeak-server
```

## ... via [`docker-compose`](https://github.com/docker/compose)

Example `docker-compose.yml` for `teaspeak`:

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

Run `docker-compose up -d`, wait for it to initialize completely, and visit `localhost:9987`, or `host-ip:9987` (as appropriate) with a TeaSpeak client.

## Where to Store Data

Important note: There are several ways to store data used by applications that run in Docker containers.
We encourage users of the `teaspeak` images to familiarize themselves with the options available, including:

- Let Docker manage the storage of your database data [by writing the database files to disk on the host system using its own internal volume management](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume).
This is the default and is easy and fairly transparent to the user. 
The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.
- Create a data directory on the host system (outside the container) and [mount this to a directory visible from inside the container](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume). 
This places the database files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. 
The downside is that the user needs to make sure that the directory exists, and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area. 

# License

View [license information]() for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
