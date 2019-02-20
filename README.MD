# This is the official TeaSpeak docker reposetory
## Build the debian docker
### Debian
Just build the docker by executing:
```
docker build --tag teaspeak:debian server/debian/
```
Running the docker:
```
docker run --rm -i teaspeak:debian
```
Run with parameters:
```
docker run --rm -i teaspeak:debian -Pgeneral.database.url=sqlite://database/TeaData.sqlite
``` 

### Ubuntu
Just build the docker by executing:  
```
docker build --tag teaspeak:ubuntu server/ubuntu/
```  
Running the docker:  
```
docker run --rm -i teaspeak:ubuntu
```  
Run with parameters:
```
docker run --rm -i teaspeak:ubuntu -Pgeneral.database.url=sqlite://database/TeaData.sqlite
```

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