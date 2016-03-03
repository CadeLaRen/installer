# Installation in a container

Instead of mounting `/var/run/docker.sock` and a `docker` client binary into an installer container,
we can use `host` namespacing, and chroot into a bind-mount of the host root dir.

## How to use it

Once the installer image is on the hub, you'll be able to make your own installers by adding a Dockerfile
to your project that looks like:

```
FROM svendowideit/installer
MAINTAINER You <You@your.org>

ADD install /install/install
```

And then write an `/install/install` script or executable that runs whatever you need to run on the host you're installing on.

```
#!/bin/sh

set -e

apt-get install stuff

docker pull someimages

wget https://your.org/docker-compose.yml

docker-compose up
```

You can also over-ride `/install/help`, which will output whenever the installer container fails to
find a matching script, or is missing some cmdline options.

You can add more commands, such as `uninstall`, `test` etc by adding more scripts into the `/install` directory. 
For example, `/install/test` would be run using `docker run --rm -v "/:/host" svendowideit/installer test`.

## Interesting results

### running mount -o rbind inside the container fails.

hopefully due to the seccomp profile
