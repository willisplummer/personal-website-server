# personal-website-server

todos:
- dockerize + deploy
- validate email addresses
- change out database for postgres, use connection  pooling
- isolate effects and test

### Update remote docker image

```
docker build . --tag willisplummer/haskell-personal-website
docker push willisplummer/haskell-personal-website:latest
```

### Deploying

```
docker build . -- tag willisplummer/haskell-personal-website:latest
heroku container:login
heroku container:push web
heroku container:release web
```
