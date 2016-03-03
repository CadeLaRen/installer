# installer

Instead of mounting `/var/run/docker.sock` and a `docker` client binary into an installer container,
we can use `host` namespacing, and chroot into a bind-mount of the host root dir.

## How to use it

Once the installer image is on the hub, you'll be able to make your own installers by adding a Dockerfile
to your project that looks like:

```
FROM svendowideit/installer
MAINTAINER You <You@your.org>

ADD install.sh /install.install.sh
```

And then write an `install.sh` that runs whatever you need to run on the host you're installing on.

```
#!/bin/sh

set -e

apt-get install stuff

docker pull someimages

wget https://your.org/docker-compose.yml

docker-compose up
```

## interesting results

### running mount -o rbind inside the container fails.

hopefully due to the seccomp profile
