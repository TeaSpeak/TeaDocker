# Supported tags and respective `Dockerfile` links

- [`latest`](https://github.com/TeaSpeak/TeaDocker/blob/master/web/Dockerfile)
- [`dev`](https://github.com/TeaSpeak/TeaDocker/blob/master/web/travis.Dockerfile)

# Quick reference

- **Where to get help**:  
  [the TeaSpeak Forums](https://forum.teaspeak.de/) or [the TeaSpeak Community Server](https://web.teaspeak.de/?connect_default=1&connect_address=ts.TeaSpeak.de)

- **Where to file issues**:  
  [TeaDocker Issue Tracker](https://github.com/TeaSpeak/TeaDocker/issues)

- **Maintained by**:  
  TeaSpeak Developer [WolverinDEV](https://github.com/WolverinDEV) and volunteer [h1dden-da3m0n](https://github.com/h1dden-da3m0n)

- **Source of this description**:  
  [`TeaDocker/server` directory](https://github.com/TeaSpeak/TeaDocker/blob/master/web/readme.md) ([history](https://github.com/TeaSpeak/TeaDocker/commits/master/web/readme.md))

# What is TeaSpeak?
> TeaSpeak is a free to use client and server software for VoIP communication. It's the ideal deal software for everyone who is annoyed about limits and restrictions.

[TeaSpeak.de](https://teaspeak.de/)

![logo](https://img.teaspeak.de/teaspeak_logo_temp.png)

# How to use this image
To start a TeaSpeak server and map the ports to the host:

```console
$ docker run -d \
    -p 80:80 -p 443:443 \
    -v $(pwd)/certs:/etc/ssl/certs \
    --restart=on-failure:3 --name teaspeak-web teaspeak/web:latest
```

Finally, you can now connect to `https://localhost` in your web-browser of choice,
you will get a self signed certificate warning, which you need to accept to proceed, 
and after accepting get loaded into yur self hosted TeaWeb client.

## Container shell access

The `docker exec` command allows you to run commands inside a Docker container. 
The following command line will give you a shell inside your `teaspeak/web` container:

```console
$ docker exec -it teaspeak-web sh
```

The TeaSpeak web (or more accurately the NginX) log is available through Docker's container log:

```console
$ docker logs teaspeak-web
# or to follow the logs
$ docker logs -f teaspeak-web
```

## ... via [`docker-compose`](https://github.com/docker/compose)

Example `docker-compose.yml` for `teaspeak`:

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

Run `docker-compose up -d`, wait for it to initialize completely, and visit `localhost:9987`, or `host-ip:9987` (as appropriate) with a TeaSpeak client.

# License

View [license information](https://github.com/TeaSpeak/TeaWeb/blob/master/LICENSE.TXT) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.