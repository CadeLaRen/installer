# svendowideit/installer:docker-custom

Re-configure the running Docker daemon.

Initially, this is coded to get the Boot2Docker daemon not to use port 2375/2376, freeing it up for use by swarm.

To install, run:

```
docker run --rm -v "/:/host" svendowideit/installer:docker-custom
```

There's a `reboot` script - tested only on boot2docker atm.

`install` will disable TLS and change the socket to 2375 - allowing swarm to use 2376.
HOWEVER, this doesn't get picked up by docker-machine, so I'll continue with that later
