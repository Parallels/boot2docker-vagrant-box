#!/bin/sh

if [ -e /var/lib/boot2docker/bin/docker-attach ] ; then
  ln -s /var/lib/boot2docker/bin/docker-attach /usr/local/bin/docker-attach
fi
