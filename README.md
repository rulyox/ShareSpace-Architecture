# Share Space Architecture

![logo](./logo.png)

Architecture for the Share Space project.

## Used Programs

* Docker

## Dependencies

1. Clone [Back-end Server](https://github.com/rulyox/ShareSpace-Back) to `./back/app`.
2. Clone [Front-end Server](https://github.com/rulyox/ShareSpace-Front) code to `./front/app`.
3. Add configurations to each directory.
4. Change `server_name` in `./nginx/server.conf`.
5. Change `MYSQL_ROOT_PASSWORD` in `./docker-compose.yml`.
6. Create database using `./mysql/schema.sql`.

## Usage

### Build Docker image

```
docker-compose build
```

### Turn on

```
docker-compose up -d
```

`share-space-back`, `share-space-nginx`, `share-space-mysql` container should be running.

`share-space-front` container should be exited.

### Turn off

```
docker-compose down
```
