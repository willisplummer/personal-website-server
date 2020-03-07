# personal-website-server

todos:
- dockerize + deploy
- validate email addresses
- change out database for postgres, use connection  pooling
- isolate effects and test


### Deploying

```
docker-compose build
docker tag  willisplummer/haskell-personal-website:latest
docker push willisplummer/haskell-blog:latest
```

## Update remote docker image

```
docker build .
docker images
```
find the image id (IMAGE_ID) of the newest image, then

```
docker tag IMAGE_ID willisplummer/haskell-personal-website
docker push willisplummer/haskell-personal-website:latest
```
