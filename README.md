# Share Space Architecture

<div align="center"> <img src="./logo.png" width=600px height=200px> </div>

Architecture for the Share Space project.

## Used Programs

* Docker

## Dependencies

1. Clone [Back-end Server](https://github.com/rulyox/ShareSpace-Back) to `./back/app`.
2. Clone [Front-end Server](https://github.com/rulyox/ShareSpace-Front) code to `./front/app`.
3. Add configurations to each directory.
4. Change `server_name` in `./nginx/server.conf`.

## Usage

### Build Docker image

```
docker-compose build
```

### Turn on

```
docker-compose up -d
```

`share-space-back` and `share-space-nginx` container should be running.

`share-space-front` container should be exited.

### Turn off

```
docker-compose down
```
