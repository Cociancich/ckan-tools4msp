# catalogue-tools4msp

Type `docker-compose` instead of `docker compose` if you use the Python tool instead of the Docker plugin, when following this README file.

## Setup

1. `docker compose up --build --force-recreate -d`

### CKAN Setup

1. [Customize site settings](http://localhost:5000/ckan-admin/config)
   1. Set `Homepage:` to the second or third choice (because of a [CSS glitch](https://github.com/ckan/ckan/issues/6542))

### Add admin

1. [Login](http://localhost:5000/user/login)
1. Set your user (`$USER`) as administrator
   1. `docker compose --profile prod exec ckan ckan -c /etc/ckan/production.ini sysadmin add $USER`

### Setup Datapusher

```bash
ckan="$(docker container ls -qf name=catalogue-tools4msp-ckan)"
db="$(docker container ls -qf name=catalogue-tools4msp-db)"
docker exec "$ckan" ckan datastore set-permissions |
    docker exec -i "$db" psql -U ckan
```

Make sure that the variable `CKAN_SITE_URL` is set to the public domain and that is reacheable from the datapusher container.
`http://ckan:5000` can be used when deploying locally, but make sure that `/etc/hosts` contains `ckan` as an alias for `localhost`.
More info at [github.com/ckan/datapusher](https://github.com/ckan/datapusher).

## Reset

This command will delete all the containers and all the volumes (`-v`).

```
docker compose --profile prod down -v
```

## Development

Run development environment with

```
# This will create the containers, ckan container will have a pdb session active
docker compose --profile dev build
docker compose --profile dev run --service-ports ckan-dev
# On source changes
[CTRL+C]
(Pdb) restart
(Pdb) c
# Stop the server
(Pdb) q
# Stop the containers
docker compose --profile prod down
```

For modifications to CSS with livereload
```
cd ckanext/ckanext-branding
npm install
npm run dev
```

# Common issues

## Solr "out of memory"

Problem: `library initialization failed - unable to allocate file descriptor table - out of memory#`
Solution: https://superuser.com/a/1413390

## Unexpected results in spatial queries

Solr indexes might need to be recreated:

```bash
ckan="$(docker container ls -qf name=catalogue-tools4msp-ckan)"
docker exec "$ckan" ckan search-index rebuild
```
