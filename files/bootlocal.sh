#!/bin/sh

if [ -e /var/lib/boot2docker/bin/docker-enter ] ; then
  ln -s /var/lib/boot2docker/bin/docker-enter /usr/local/bin/docker-enter
  ln -s /var/lib/boot2docker/bin/docker-enter /usr/local/bin/docker-attach
fi
