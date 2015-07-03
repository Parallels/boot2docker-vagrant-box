# boot2docker Vagrant Box

This repository contains the scripts necessary to create a
[boot2docker](https://github.com/steeve/boot2docker) Vagrant box compatible with
[Parallels provider](https://github.com/Parallels/vagrant-parallels).
If you work solely with Docker, this box lets you keep your Vagrant workflow and
work in the most minimal Docker environment possible.

## Docker installation
Docker client should be installed on your Mac.
You can do it via official [boot2docker](https://docs.docker.com/installation/mac/)
installer or [Homebrew](http://brew.sh/): `brew install docker`

## Usage

The box is available on [Atlas](https://atlas.hashicorp.com/dduportal/boxes/boot2docker),
making it very easy to use it:

```bash
vagrant init parallels/boot2docker
vagrant up
```

Then you need to configure your Docker environment:

```bash
export DOCKER_CERT_PATH=`pwd`/tls
export DOCKER_HOST="tcp://`vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"`:2376"
```

That's it! Now your VM can be used as Docker host, check it:

```bash
docker version
...
```

If you want the actual box file, you can download it from the
[releases page](https://github.com/Parallels/boot2docker-vagrant-box/releases).

## Tips & tricks

* Vagrant synced folders has been tested with :
  * Parallels Shared Folders : This is default sharing system for Parallels provider
  * [NFS](https://docs.vagrantup.com/v2/synced-folders/nfs.html) :
  Set `B2D_NFS_SYNC` environment variable to use NFS for sharing folders:

    ```bash
    $ export B2D_NFS_SYNC=1
    $ vagrant up
    ```

* If you want to tune contents (custom profile, install tools inside the VM),
just place a `bootlocal.sh` script alongside your Vagrantfile.
It will be run in the VM automatically each time after `vagrant up`.
Refer to [boot2docker FAQ](https://github.com/boot2docker/boot2docker/blob/master/doc/FAQ.md)
to get more details.

* This box is pre-configured to sync TLS certificates with your Mac after
every `vagrant up`. Certificates appears at `./tls/` directory. If you want to
regenerate them, just run:

```bash
vagrant ssh -c "sudo /etc/init.d/docker restart && sudo cp -r /var/lib/boot2docker/tls `pwd`/"
```

## Building the Box

If you want to recreate the box, rather than using the binary, then
you can use the scripts and Packer template within this repository to
do so in seconds.

To build the box, first install the following prerequisites:

  * [Packer](http://www.packer.io) (at least version 0.7.5)
  * [Parallels Desktop for Mac](http://www.parallels.com/products/desktop/) (version 10.1.2 or higher)
  * [Parallels Virtualization SDK for Mac](http://www.parallels.com/download/pvsdk/)
  * [Bats](https://github.com/sstephenson/bats) for integration tests

Then run this command to build the box for Parallels provider:

```
make parallels
```

## Authors

- Author:: Mikhail Zholobov (<legal90@gmail.com>)
- Author:: Damien Duportal (<damien.duportal@gmail.com>)
