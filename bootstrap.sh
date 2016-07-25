#!/bin/sh

set -e

if [[ ! -d "/host" ]]; then
	/install/help $@
	exit 255
fi

# make sure we have the --network host
CONTAINERNAME=`cat /etc/hostname`
HOSTNAME=`cat /host/etc/hostname`
echo "test $HOSTNAME vs $CONTAINERNAME"
if [[ "$HOSTNAME" != "$CONTAINERNAME" ]]; then
	echo "$HOSTNAME ne $CONTAINERNAME, restarting with --net host"
	# have to assume the hostname == containername, so we can use `docker inspect`
	IMAGENAME=`chroot /host docker inspect --format "{{ .Config.Image }}" $(hostname)`

	# TODO: I wonder if there's a way to detect if we have a tty or not

	chroot /host docker run --net host -v /:/host --rm $IMAGENAME $@
else
	CMD="$1"
	if [[ -z $CMD ]]; then
		CMD="install"
	fi

	CMDLINE="/install/$CMD"
	if [[ ! -e "$CMDLINE" ]]; then
		echo ""
		echo "ERROR: No command '$CMD' found"
		echo ""
		/install/help $@
		exit 254
	fi

	# remove $CMD from argc
	shift

	DIR=$(mktemp -d -p /host)
	cp -r /install/* $DIR

	# Need to know the tmpdir inside the chroot too
	HOSTDIR=$(echo $DIR | sed "s/\/host//")
	echo "entering host chroot running '$CMD $@'"

	# can't use exec, as we'd like to remove the temp dir from the host FS
	chroot /host "$HOSTDIR/$CMD" $@

	echo "cleaning up tmpdir"
	rm -r $DIR
fi
