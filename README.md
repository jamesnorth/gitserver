cgit Based Git Server
====
this repo contains my self-hosted git server configuration. It's a cgit based Docker container.

# Build & Run the Container
It is pretty staightforward to build the container, run `docker build`, like this:
```
docker build -t cgitserver .
```

Runnig the container requires a few options, like setting the volume and port mapping.

```
docker run --rm --name cgit -p 8080:80 -v $(pwd)/repos:/repos cgitserver
```
