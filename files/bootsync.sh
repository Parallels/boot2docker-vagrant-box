#!/bin/sh

# Start NFS client for NFS synced folder
if [ -x /usr/local/etc/init.d/nfs-client ]; then
  /usr/local/etc/init.d/nfs-client start
fi

# Place docker in /usr/bin for guest capability check
ln -s /usr/local/bin/docker /usr/bin/docker
