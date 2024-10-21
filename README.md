# deploio-matomo
Repo with Dockerfile for Matomo Build on deplo.io

Command to create the application:

```
nctl create application matomo \
  --git-url=https://github.com/thomhug/deploio-matomo \
  --dockerfile \
  --port=80 \
  --env=MATOMO_DATABASE_HOST=<dbhost> \
  --env=MATOMO_DATABASE_USERNAME=dbadmin \
  --env=MATOMO_DATABASE_PASSWORD=<pw> \
  --env=MATOMO_DATABASE_DBNAME=matomo_db \
  --env=MATOMO_DATABASE_PORT=3306
```
