# This is the official TeaSpeak docker reposetory
## Build the debian docker
### Debian
Just build the docker by executing:  
`docker build --tag teaspeak:debian debian/`  
Running the docker:  
`docker run --rm -i teaspeak:debian`  
Run with parameters:
`docker run --rm -i teaspeak:debian -Pgeneral.database_url=sqlite://database/TeaData.sqlite`
### Ubuntu
Just build the docker by executing:  
`docker build --tag teaspeak:ubuntu ubuntu/`  
Running the docker:  
`docker run --rm -i teaspeak:ubuntu`  
Run with parameters:
`docker run --rm -i teaspeak:ubuntu -Pgeneral.database_url=sqlite://database/TeaData.sqlite`