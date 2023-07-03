# Prerequisite and Intallation

I. Install requirements

1. Install docker and docker compose

+ [Docker](https://docs.docker.com/engine/install/)
+ [Docker compose plugin](https://docs.docker.com/compose/install/linux/)


2. Clone this project to your computer

```shell
git clone https://gitlab.com/xmars/odoo-docker -b 16 --depth=1 $HOME/odoo-16-docker
```

II. Build odoo image

1. Update latest Odoo release version in **docker-files/Dockerfile**

+ Access site [Odoo nightly](http://nightly.odoo.com/16.0/nightly/deb/)
+ Get latest version code (by release date). e.g: 12-Mar-2023 -> latest version = *20230312*
+ Get checksum file: e.g: latest version 20230312 -> checksum file name = *odoo_16.0.20230312_amd64.changes*<br/><br/>
  <img src="img/nightly-release.png" alt="alt text" width="300" height="120">

+ Get checksum code sha1: e.g: checksum code = *840c008a9bc0494d3a64a124b68c6f471ce333c9* <br/><br/>
  <img src="img/release-checksum.png" alt="alt text" width="300" height="176">
+ Update content to docker file

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

3. (optional) Push newly image to Docker hub

```shell
docker login
docker push xmars/odoo:16
```

4. (optional) if you want to install some libs, edit **docker-files/requirements.txt** and **docker-files/entrypoint.sh
   **
   and build new image

# Running Odoo docker compose

1. Copy custom addons to folder **extra-addons**
2. Copy enterprise addons to folder **et-addons**
3. Edit file config in **etc/odoo.conf** if you want to add some configuration
4. Running Odoo

```shell
cd $HOME/odoo-16-docker
docker compose up -d
```

5. DONE, your Odoo instance will run on  [http://localhost:8069](http://localhost:8069)
6. If you want update modules on next restart,

+ Add two params to **etc/odoo.conf** file

```
...
db_name = <db name>
update_addons = <list addons to update, separate by comma>
```

+ Restart services

```shell
docker compose restart
```

7. Check file log in **logs/odoo.log**

# Tip and Tricks

+ [generate records for testing](https://www.odoo.com/documentation/16.0/developer/reference/cli.html#database-population)

```shell
  docker exec <odoo_container_name_or_id> odoo populate --models res.partner,product.product --size medium -c /etc/odoo/odoo.conf
```

+ run postgresql by docker

```shell
docker run --name postgresql-15 -p 5432:5432  -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin -e POSTGRES_DB=postgresdb  -d --restart unless-stopped postgres:15
```

+ Clean docker resources

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

# Problems and Solutions

+ If you run docker compose in Windows and got problem

```shell
entrypoint.sh file not found
```

+ open file this project in [VSCode](https://code.visualstudio.com/download)
  or [Pycharm](https://www.jetbrains.com/pycharm/download/)
+ make sure encoding option and line separator is correct <br/>
  <img src="img/encoding-problem.png" alt="alt text" width="400" height="176">

