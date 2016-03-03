# installer

Instead of mounting `/var/run/docker.sock` and a `docker` client binary into an installer container,
we can use `host` namespacing, and chroot into a bind-mount of the host root dir.

## interesting results

### running mount -o rbind inside the container fails.

hopefully due to the seccomp profile
