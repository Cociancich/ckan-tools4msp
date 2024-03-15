# catalogue-tools4msp
This repository contains a customized ckan setup originally developed by ismar for tools4msp catalogue
here you can find the [original repo](https://gitlab.com/gisdev.io/catalogue-tools4msp) 


## Preparation
install Docker and docker compose

clone this repository into a local directory. To run this stack  in localhost:

copy `docker-compose_localhost` to `docker-compose.yml`

move into traefik directory
`cd traefik`

start traefik proxy 
`docker compose up -d`

Type `docker-compose` instead of `docker compose` if you use the Python tool instead of the Docker plugin, when following this README file.

This will start a traefik instance that will route the http requests to docker containers according to docker compose configuration

## Setup
Move back to starting directory

1. `docker compose  up --build --force-recreate -d`

Ckan should be available on (http://localhost/ckan)

### CKAN Setup


1. [Customize site settings](http://localhost/ckan//ckan-admin/config)
   1. Set `Homepage:` to the second or third choice (because of a [CSS glitch](https://github.com/ckan/ckan/issues/6542))

### Add admin
1. register a new user (e.g. ckan) and [Login](http://localhost/ckan/user/login)
1. Set your user (`$USER`) as administrator
   1. `docker compose exec ckan ckan -c /etc/ckan/production.ini sysadmin add $USER`

## Reset

This command will delete all the containers and all the volumes (`-v`).

```
docker compose --profile prod down -v
```


For modifications to CSS with livereload
```
cd ckanext/ckanext-branding
npm install
npm run dev
```

# Tools

## spreadsheet_to_schema.sh

The script generates a partial CKAN JSON schema from a data cluster spreadsheet, that can be merged into one an existing schema. It also produces a brief report in Markdown in the terminal (standard output).

1. Be sure to have [duckdb](https://duckdb.org/) and [jq](https://jqlang.github.io/jq/) installed
2. Edit `spreadsheet_to_schema.sh` parameters `SPREADSHEET` and `WORKSHEET` to match your data cluster filename path and worksheet name
3. Run `spreadsheet_to_schema.sh`
4. Integrate the changes back into `ckanext/ckanext-schemas/ckanext/schemas/msp_data.json`

[meld](https://meldmerge.org/) is the suggested graphical tool to check the differences between the complete schema file and the partial one, generated from the data cluster file. It can be executed like this:

```bash
meld ckanext/ckanext-schemas/ckanext/schemas/itoos_data.json struttura.json
```

# Common issues

## Solr "out of memory"

Problem: `library initialization failed - unable to allocate file descriptor table - out of memory#`
Solution: https://superuser.com/a/1413390

## Datapusher cannot open URL

Example: `URLError: <urlopen error [Errno 99] Cannot assign requested address>`

Datapusher tries to access the URL of the resource, which is a public URL.
Make sure that the variable `CKAN_SITE_URL` is set to the public domain and that is reacheable from the datapusher container.
`http://ckan:5000` can be used when deploying locally, but make sure that `/etc/hosts` contains `ckan` as an alias for `localhost`.

## Unexpected results in spatial queries

Solr indexes might need to be recreated:

```bash
ckan="$(docker container ls -qf name=catalogue-tools4msp-ckan)"
docker exec "$ckan" ckan search-index rebuild
```
