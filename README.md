

# Use a Docker Swarm service to upgrade, update or configuration manage your Swarm hosts.

Its possible to use a `docker service` to update _all_ the hosts in your Swarm.

If you've planned ahead, you may have added `list-restore: true` to your `/etc/docker/daemon.json` - and so you'll experience magic when there's a new Docker Engine update too.

I've made an image on the hub called `svendowideit/update-swarm-installer` which will (er, Debian example) update all your installed debian packages, and then install `vim-tiny`.

Assuming you have 6 swarm nodes, and your managers havn't been set up drained (ie, no containers will be started on them), you can run the following:

	docker service create --name update --restart-condition=none --replicas=6 --mount source=/,target=/host,type=bind,writable=true svendowideit/update-swarm-installer

This will tell Docker Swarm to start the image 6 times (ie, one on each host) once, and only once.

The `--mount source=/,target=/host,type=bind,writable=true` gives the container access to the node's host filesystem - and then the "installer" base image takes over.

## Details

The `svendowideit/update-swarm-installer` image is built using a very simple `Dockerfile`:

```
FROM svendowideit/installer
MAINTAINER Sven Dowideit <SvenDowideit@home.org.au>
ADD install /install/install
```

and the "install" script is exactly the commands we'd like to run on each host, plus something that will stop the container from existing - allowing me to demonstrate the creation of the containers.

```
#!/bin/sh

set -e

apt-get update
apt-get dist-upgrade -yq
apt-get install vim-tiny -yq

#finished - this will sit there so `docker service tasks update` can be useful
tail -f /etc/hostname
```
