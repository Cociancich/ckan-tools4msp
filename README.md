# catalogue-tools4msp

## Setup

1. `docker-compose up --build --force-recreate -d`

### CKAN Setup

1. [Customize site settings](http://localhost:5000/ckan-admin/config)
   1. Set `Homepage:` to the second or third choice (because of a [CSS glitch](https://github.com/ckan/ckan/issues/6542))

### Add admin

1. [Login](http://localhost:5000/user/login)
2. Set your user (`$user`) as administrator
   1. `docker-compose exec ckan ckan -c /etc/ckan/production.ini sysadmin add $user`

## Reset

This command will delete all the containers and all the volumes (`-v`).

``` 
docker-compose down -v
```

## Development

Run development environment with

```
# This will create the containers, ckan container will have a pdb session active
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --force-recreate -d
# So attach to the session
docker attach catalogue-tools4msp_ckan
# Start the server
(Pdb) c
# On source changes
(Pdb) restart
(Pdb) c
```

For modifications to CSS with livereload
```
cd cnext/cnext-branding
npm install
npm run dev
```