# boot2docker Vagrant Box

This repository contains the scripts necessary to create a Vagrant-compatible
[boot2docker](https://github.com/boot2docker/boot2docker) box. If you work solely
with Docker, this box lets you keep your Vagrant workflow and work in the
most minimal Docker environment possible.

## Docker installation
Docker client need to be installed on your Mac.
You can do it via [Brew](http://brew.sh/) `brew install docker` or use official [boot2docker](https://docs.docker.com/installation/mac/) installer.

## Usage

If you just want to use the box, then download the latest box from
the [releases page](https://github.com/Parallels/boot2docker-vagrant-box/releases)
and `vagrant up` as usual! Or, if you don't want to leave your terminal:

    $ vagrant plugin install vagrant-parallels
    $ vagrant init parallels/boot2docker
    $ vagrant up --provider parallels
    $ export DOCKER_HOST="tcp://`vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"`:2375"
    $ docker version

![Vagrant Up Boot2Docker](https://raw.github.com/Parallels/boot2docker-vagrant-box/master/readme_image.gif)

## Building the Box

If you want to recreate the box, rather than using the binary, then
you can use the Packer template and sources within this repository to
do it in seconds.

To build the box, first install the following prerequisites:

  * [Packer](http://www.packer.io) (at least version 0.5.2, 0.6.1 for Parallels)
  * [Parallels Desktop](http://www.parallels.com/products/desktop/)

Then, just run `make parallels`. The resulting box will be named `boot2docker-parallels.box`.
The entire process to make the box takes about 20 seconds.

## License

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.

- [boot2docker](http://boot2docker.io/) is under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0).
- [Vagrant](http://www.vagrantup.com/): Copyright (c) 2010-2014 Mitchell Hashimoto, under the [MIT License](https://github.com/mitchellh/vagrant/blob/master/LICENSE)
