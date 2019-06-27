#!/bin/sh

. $TESTSLIB/snap-names.sh

# Remove all snaps not being the core, gadget, kernel or snap we're testing
for snap in /snap/*; do
	snap="${snap:6}"
	case "$snap" in
		"bin" | "$gadget_name" | "$kernel_name" | core* | "$SNAP_NAME" )
			;;
		*)
			snap remove "$snap"
			;;
	esac
done

# Cleanup all configuration files from ModemManager so that we have
# a fresh start for the next test
rm -rf /var/snap/modem-manager/common/*
rm -rf /var/snap/modem-manager/current/*
systemctl stop snap.modem-manager.modemmanager

# Ensure we have the same state for snapd as we had before
systemctl stop snapd.service snapd.socket
rm -rf /var/lib/snapd/*
$(cd / && tar xzf $SPREAD_PATH/snapd-state.tar.gz)
rm -rf /root/.snap
systemctl start snapd.service snapd.socket

# Bringup ModemManager again now that the system is restored
systemctl start snap.modem-manager.modemmanager
