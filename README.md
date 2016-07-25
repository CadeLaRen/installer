

# Use a Docker Swarm service to upgrade, update or configuration manage your Swarm hosts.

Its possible to use a `docker service` to update _all_ the hosts in your Swarm.

If you've planned ahead, you may have added `list-restore: true` to your `/etc/docker/daemon.json` - and so you'll experience magic when there's a new Docker Engine update too.

I've made an image on the hub called `svendowideit/update-swarm-installer` which will (er, Debian example) update all your installed debian packages, and then install `vim-tiny`.

Assuming you have 6 swarm nodes, and your managers havn't been set up drained (ie, no containers will be started on them), you can run the following:

	docker service create --name update --restart-condition=none --replicas=6 --mount source=/,target=/host,type=bind,writable=true svendowideit/update-swarm-installer

This will tell Docker Swarm to start the image 6 times (ie, one on each host) once, and only once.

The `--mount source=/,target=/host,type=bind,writable=true` gives the container access to the node's host filesystem - and then the "installer" base image takes over.

## An example run

Starting with a Docker v1.12-rc3 ubuntu swarm:

```
ubuntu@n3:~$ docker version
Client:
 Version:      1.12.0-rc3
 API version:  1.24
 Go version:   go1.6.2
 Git commit:   91e29e8
 Built:        Sat Jul  2 00:40:04 2016
 OS/Arch:      linux/amd64
 Experimental: true

Server:
 Version:      1.12.0-rc3
 API version:  1.24
 Go version:   go1.6.2
 Git commit:   91e29e8
 Built:        Sat Jul  2 00:40:04 2016
 OS/Arch:      linux/amd64
 Experimental: true
ubuntu@n3:~$ docker info
Containers: 24
 Running: 2
 Paused: 0
 Stopped: 22
Images: 4
Server Version: 1.12.0-rc3
Storage Driver: aufs
 Root Dir: /var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 57
 Dirperm1 Supported: false
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: null host bridge overlay
Swarm: active
 NodeID: 0bor9fv8zerwia44z77dftjt0
 IsManager: Yes
 Managers: 1
 Nodes: 5
 CACertHash: sha256:3236338debf5db448222fe3761ec1498c92e245dba48c041d2079895b21db91d
Runtimes: runc
Default Runtime: runc
Security Options: apparmor seccomp
Kernel Version: 3.13.0-91-generic
Operating System: Ubuntu 14.04.4 LTS
OSType: linux
Architecture: x86_64
CPUs: 1
Total Memory: 1.954 GiB
Name: n3.fi.gy
ID: VZBM:43UU:DK4W:4HK5:OLZM:RCDU:CYSH:LECS:LXNB:NHWA:BFQU:MGGO
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
WARNING: No swap limit support
Experimental: true
Insecure Registries:
 127.0.0.0/8
```

I start my service:

```
$ docker service create --name update --restart-condition=none --replicas=6 --mount source=/,target=/host,type=bind,writable=true svendowideit/update-swarm-installer
4z2atjadex2epiqj32lkhjplz
```

and spend some time waiting for things to stableize and be running:


```
ubuntu@n3:~$ docker service ls
ID            NAME      REPLICAS  IMAGE                                COMMAND
4hpycktuf2v6  web       10/10     nginx                                
4z2atjadex2e  update    0/6       svendowideit/update-swarm-installer  
azznbr600edk  terminal  1/1       test                                 
ubuntu@n3:~$ docker service ls
ID            NAME      REPLICAS  IMAGE                                COMMAND
4hpycktuf2v6  web       10/10     nginx                                
4z2atjadex2e  update    0/6       svendowideit/update-swarm-installer  
azznbr600edk  terminal  1/1       test                                 
ubuntu@n3:~$ docker ps
CONTAINER ID        IMAGE                                        COMMAND                  CREATED              STATUS              PORTS               NAMES
01202f5aa493        svendowideit/update-swarm-installer:latest   "/bootstrap.sh"          3 seconds ago        Up 3 seconds                            update.2.4wqic513pgdp15rouccn0ui33
0698d377fa3d        nginx:latest                                 "nginx -g 'daemon off"   About a minute ago   Up About a minute   80/tcp, 443/tcp     web.8.a9ftbpn4fheciswjbo12r9l6r
aed836e3d9b4        test:latest                                  "/bin/sh -c 'tail -f "   3 days ago           Up 3 days                               terminal.1.cc9mjvheudt1r4re4gpdqboth
ubuntu@n3:~$ docker service ls
ID            NAME      REPLICAS  IMAGE                                COMMAND
4hpycktuf2v6  web       10/10     nginx                                
4z2atjadex2e  update    4/6       svendowideit/update-swarm-installer  
azznbr600edk  terminal  1/1       test                                 
ubuntu@n3:~$ docker service ls
ID            NAME      REPLICAS  IMAGE                                COMMAND
4hpycktuf2v6  web       10/10     nginx                                
4z2atjadex2e  update    4/6       svendowideit/update-swarm-installer  
azznbr600edk  terminal  1/1       test
$ docker service  tasks update
ID                         NAME      SERVICE  IMAGE                                LAST STATE          DESIRED STATE  NODE
4wqic513pgdp15rouccn0ui33  update.2  update   svendowideit/update-swarm-installer  Running 33 seconds  Running        n3.fi.gy
czfwurmkfyvsilczmp84hf9tp  update.3  update   svendowideit/update-swarm-installer  Running 33 seconds  Running        n7.fi.gy
e3acms8w9m2zcvyec84ejp6qh  update.6  update   svendowideit/update-swarm-installer  Running 33 seconds  Running        n6.fi.gy
ubuntu@n3:~$ 
ubuntu@n3:~$ 
ubuntu@n3:~$ docker service  tasks update
ID  NAME  SERVICE  IMAGE  LAST STATE  DESIRED STATE  NODE
```

And clearly, something went wrong before the `install` script got to the `tail -f`, so we can use the container's `docker logs` to debug:


```
ubuntu@n3:~$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS               NAMES
0698d377fa3d        nginx:latest        "nginx -g 'daemon off"   About a minute ago   Up About a minute   80/tcp, 443/tcp     web.8.a9ftbpn4fheciswjbo12r9l6r
aed836e3d9b4        test:latest         "/bin/sh -c 'tail -f "   3 days ago           Up 3 days                               terminal.1.cc9mjvheudt1r4re4gpdqboth
ubuntu@n3:~$ docker ps -a
CONTAINER ID        IMAGE                                        COMMAND                  CREATED             STATUS                        PORTS               NAMES
01202f5aa493        svendowideit/update-swarm-installer:latest   "/bootstrap.sh"          49 seconds ago      Exited (100) 22 seconds ago                       update.2.4wqic513pgdp15rouccn0ui33
0698d377fa3d        nginx:latest                                 "nginx -g 'daemon off"   2 minutes ago       Up 2 minutes                  80/tcp, 443/tcp     web.8.a9ftbpn4fheciswjbo12r9l6r
2939d7bd4f4f        nginx:latest                                 "nginx -g 'daemon off"   3 days ago          Exited (0) 2 minutes ago                          web.9.048cqhv33jayyvj8g5dvnmacc
...
```

```
ubuntu@n3:~$ docker logs update.2.4wqic513pgdp15rouccn0ui33 

...

Done.
Unpacking linux-image-3.13.0-92-generic (3.13.0-92.139) ...
Preparing to unpack .../docker-engine_1.12.0~rc4-0~trusty_amd64.deb ...
initctl: Unable to connect to Upstart: Failed to connect to socket /com/ubuntu/upstart: Connection refused
 * Stopping Docker: docker
No process in pidfile '/var/run/docker-ssd.pid' found running; none killed.
invoke-rc.d: initscript docker, action "stop" failed.
dpkg: warning: subprocess old pre-removal script returned error exit status 1
dpkg: trying script from the new package instead ...
initctl: Unable to connect to Upstart: Failed to connect to socket /com/ubuntu/upstart: Connection refused
 * Stopping Docker: docker
No process in pidfile '/var/run/docker-ssd.pid' found running; none killed.
invoke-rc.d: initscript docker, action "stop" failed.
dpkg: error processing archive /var/cache/apt/archives/docker-engine_1.12.0~rc4-0~trusty_amd64.deb (--unpack):
 subprocess new pre-removal script returned error exit status 1
dpkg: error while cleaning up:
 subprocess installed post-installation script returned error exit status 1

...

```

So we've had some issue contacting the host's DBus - yeah, I need to fix that in the installer startup :/

I think this needs the containers to be started in the host's network namespace, which it __looks__ like
I can't do directly:

```
ubuntu@n3:~$ docker service create --name update --restart-condition=none --replicas=6 --network host --mount source=/,target=/host,type=bind svendowideit/update-swarm-installer
Error response from daemon: network host not found
```

BUT... once we have access to the host's docker socket, we should be able to create another container that does the job.

So

## SUCCESS

I modified the `svendowideit/installer` base image's bootstrap.sh to restart the same image with the same parameters
but adding `--net host` to the commandline if it detects that it hasn't been.

and with that in place, I was able to upgrade from Docker 1.12.-rc3 to v1.12-rc4 using a single Swarm service command.

_and_ I also changed to using a `--mode=global` service to ensure that I'm running one update task per node:

```
ubuntu@n3:~$ docker service rm update
ubuntu@n3:~$ docker service create --name update --restart-condition=none --mode=global  --mount source=/,target=/host,type=bind svendowideit/update-swarm-installer
5llw2izg855gvmjp09cmypbeq
ubuntu@n3:~$ docker service tasks update
ID                         NAME    SERVICE  IMAGE                                LAST STATE              DESIRED STATE  NODE
1wql23wcgm2mb0hznq0t9zgdw  update  update   svendowideit/update-swarm-installer  Running 15 seconds ago  Running        n6.fi.gy
ev0o6vjmeydxqu84re1j6bxj1  update  update   svendowideit/update-swarm-installer  Running 15 seconds ago  Running        ip-172-31-41-85
0pvjmjuowiwphjxfsrnyiw20a  update  update   svendowideit/update-swarm-installer  Running 15 seconds ago  Running        n4.fi.gy
1r67tf4cote9xhpfwg9jzermc  update  update   svendowideit/update-swarm-installer  Running 15 seconds ago  Running        n7.fi.gy
0tghwwsj5cd3iw1332q305rqw  update  update   svendowideit/update-swarm-installer  Running 15 seconds ago  Running        n3.fi.gy
ubuntu@n3:~$ docker ps
CONTAINER ID        IMAGE                                        COMMAND                  CREATED             STATUS              PORTS               NAMES
dd8ddb7c096a        svendowideit/update-swarm-installer:latest   "/bootstrap.sh"          9 seconds ago       Up 8 seconds                            ecstatic_perlman
e430c93ced85        svendowideit/update-swarm-installer:latest   "/bootstrap.sh"          12 seconds ago      Up 11 seconds                           update.0.0tghwwsj5cd3iw1332q305rqw
f2e92a04f377        nginx:latest                                 "nginx -g 'daemon off"   About an hour ago   Up About an hour    80/tcp, 443/tcp     web.4.4nf18i6i1o3ww5wnp2bvfj4pq
fd68d993026e        nginx:latest                                 "nginx -g 'daemon off"   About an hour ago   Up About an hour    80/tcp, 443/tcp     web.10.3j0o9c3fguhiwu3swts587cmi
ac41db029764        nginx:latest                                 "nginx -g 'daemon off"   About an hour ago   Up About an hour    80/tcp, 443/tcp     web.8.e1jsn8c7717sts8fndmerbnjz
b80eb2c72e0b        nginx:latest                                 "nginx -g 'daemon off"   About an hour ago   Up About an hour    80/tcp, 443/tcp     web.7.3ppb58u5jkz8kzhzugn6zegnr
e8293fc9e2a0        nginx:latest                                 "nginx -g 'daemon off"   About an hour ago   Up About an hour    80/tcp, 443/tcp     web.5.6jo30vg21527hp7zpx32ohuep
bdc7caf16d57        nginx:latest                                 "nginx -g 'daemon off"   About an hour ago   Up About an hour    80/tcp, 443/tcp     web.9.a92dajrgehprf08973l64yfnt
13b470eef0d0        nginx:latest                                 "nginx -g 'daemon off"   About an hour ago   Up About an hour    80/tcp, 443/tcp     web.1.b81vm64fwpp0dxdmvznnvrl9h
ubuntu@n3:~$ docker logs update.0.0tghwwsj5cd3iw1332q305rqw
trying to get image running using e430c93ced85
test svendowideit/update-swarm-installer:latest
Adding --net host to startup of svendowideit/update-swarm-installer:latest 
latest: Pulling from svendowideit/update-swarm-installer
Digest: sha256:9b869172e1c2da3bbfa0693a19838c15d19278f6d954bfda77cd49fad39a3da3
Status: Image is up to date for svendowideit/update-swarm-installer:latest
trying to get image running using n3.fi.gy
Error: No such image, container or task: n3.fi.gy
test 
entering host chroot running 'install '
Ign http://ap-southeast-2.ec2.archive.ubuntu.com trusty InRelease
Get:1 http://ap-southeast-2.ec2.archive.ubuntu.com trusty-updates InRelease [65.9 kB]
Hit http://ap-southeast-2.ec2.archive.ubuntu.com trusty-backports InRelease
Hit http://ap-southeast-2.ec2.archive.ubuntu.com trusty Release.gpg
Hit http://ap-southeast-2.ec2.archive.ubuntu.com trusty Release
...

```

All the nodes now have an `update` task sitting, waiting to be killed (allowing you to review the (er, some?) of the log output.

You can also see that the `update.0.0tghwwsj5cd3iw1332q305rqw` container, started by swarm, then started a child to add `--net=host` so that the services can be restarted.

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


