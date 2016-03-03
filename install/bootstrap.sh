#!/bin/sh

set -e

if [[ ! -d "/host" ]]; then
	echo "Please start this container with the following parameters:"
	echo ""
	echo "   docker run --rm -it -v \"/:/host\" install"
	echo ""
	exit 255
fi

cp -r /install /host/
echo "entering chroot"
exec chroot /host /install/install.sh
