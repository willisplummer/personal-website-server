# personal-website-server

todos:
- validate email addresses
- connection  pooling
- isolate effects and test
- ssl

### Update remote docker image

```
docker build . --tag willisplummer/haskell-personal-website --cache-from willisplummer/haskell-personal-website:latest
docker push willisplummer/haskell-personal-website:latest
```

### Deploying

```
heroku container:login
heroku container:push web -a heroku-personal-website
heroku container:release web -a heroku-personal-website
```

### Migrating the heroku db

- get the database url (DB_URL) from the heroku config vars
- `stack build`
- `DATABASE_URL=DB_URL stack exec migrate-db-exe`
