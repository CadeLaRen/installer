#!/bin/sh

set -e

if [[ ! -d "/host" ]]; then
	/install/help.sh $@
	exit 255
fi

CMD="$1"
if [[ -z $CMD ]]; then
	CMD="install"
fi

CMDLINE="/install/$CMD.sh"
if [[ ! -e "$CMDLINE" ]]; then
	echo "No command '$CMD' found"
	/install/help.sh $@
	exit 254
fi

# remove $CMD from argc
shift

cp -r /install /host/
echo "entering host chroot running '$CMD $@'"
exec chroot /host "$CMDLINE" $@
