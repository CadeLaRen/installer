# svendowideit/installer:docker-custom

Re-configure the running Docker daemon.

Initially, this is coded to get the Boot2Docker daemon not to use port 2375/2376, freeing it up for use by swarm.

To install, run:

```
docker run --rm -v "/:/host" svendowideit/installer:docker-custom
```
