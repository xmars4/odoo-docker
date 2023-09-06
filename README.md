# Prerequisite and Installation

Install docker and docker compose

- [Docker](https://docs.docker.com/engine/install/)
- [Docker compose plugin](https://docs.docker.com/compose/install/linux/)

# Running Odoo

1. Clone this project to your computer

```shell
ODOO_DOCKER_PATH=$HOME/odoo-docker
git clone https://gitlab.com/xmars/odoo-docker -b 16 --depth=1 $ODOO_DOCKER_PATH
```

2. Copy custom addons to folder **extra-addons**

3. Copy enterprise addons to folder **et-addons**

4. Edit file config in **etc/odoo.conf** if you want to add some configuration

5. Running Odoo

```shell
cd $ODOO_DOCKER_PATH
docker compose up -d
```

6. DONE, your Odoo instance will running on [http://localhost:18069](http://localhost:18069)

7. _(Optional)_ Setup log rotate (on host machine)

```shell
cd $ODOO_DOCKER_PATH/scripts
sudo /bin/bash setup-logrotate.sh
```

8. _(Optional)_ If you want update modules on next restart,

- Add two params to **etc/odoo.conf** file

```
...
db_name = <db name>
update_addons = <list addons to update, separate by comma>
```

- Restart services

```shell
docker compose restart
```

# Build and push Odoo image to Docker hub

1. Update latest Odoo release version in **docker-files/Dockerfile**

- Access site [Odoo nightly](http://nightly.odoo.com/16.0/nightly/deb/)
- Get latest version code (by release date). e.g: 12-Mar-2023 -> latest version = _20230312_
- Get checksum file: e.g: latest version 20230312 -> checksum file name = _odoo_16.0.20230312_amd64.changes_<br/><br/>
  <img src="img/nightly-release.png" alt="alt text" width="300" height="120">

- Get checksum code sha1: e.g: checksum code = _840c008a9bc0494d3a64a124b68c6f471ce333c9_ <br/><br/>
  <img src="img/release-checksum.png" alt="alt text" width="300" height="176">
- Update content to docker file

```dockerfile
...
ARG ODOO_RELEASE=<latest version>
ARG ODOO_SHA=<checksum code>
...
```

2. Run build command

```shell
cd $HOME/odoo-16-docker/docker-files
docker build -f Dockerfile -t xmars/odoo:16 .
# add multiple tag to image. e.g:
# docker build -f Dockerfile -t xmars/odoo:16 -t xmars/odoo:16.20230312 .
```

3. _(Optional)_ Push newly image to Docker hub

```shell
docker login
docker push xmars/odoo:16
```

4. _(Optional)_ if you want to install some libs, edit **docker-files/requirements.txt** <br/> and **docker-files/entrypoint.sh** and build new image

# Tip and Tricks

- [generate records for testing](https://www.odoo.com/documentation/16.0/developer/reference/cli.html#database-population)

```shell
  docker exec <odoo_container_name_or_id> odoo populate --models res.partner,product.product --size medium -c /etc/odoo/odoo.conf
```

- run postgresql by docker

```shell
docker run --name postgresql-15 -p 5432:5432 \
 -e POSTGRES_USER=admin \
 -e POSTGRES_PASSWORD=admin \
 -e POSTGRES_DB=postgresdb \  
 -d --restart unless-stopped \
 postgres:15
```

- Clean docker resources

```shell
# Prune every unused docker objects
docker system prune --volumes -f

# Remove dangling volumes
docker volume rm -f $(docker volume ls -f dangling=true)

# Remove exited container
docker rm -f $(docker ps --filter status=exited -q)

# Docker removes dangling (<none> tag) image
docker rmi $(sudo docker images -f "dangling=true" -q)

# Display full content of all tag for container
docker ps --no-trunc -a
```

- Test logrotate works properly
```shell
sudo /usr/sbin/logrotate /etc/logrotate.conf -v
```

# Problems and Solutions

- If you run docker compose in Windows and got problem

```shell
entrypoint.sh file not found
```

- open file this project in [VSCode](https://code.visualstudio.com/download)
  or [Pycharm](https://www.jetbrains.com/pycharm/download/)
- make sure encoding option and line separator is correct <br/>
  <img src="img/encoding-problem.png" alt="alt text" width="400" height="176">
