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

Then you need to prepare your environment for Docker client

### If TLS is enabled (by default):

```bash
# Copy TLS certificates from the VM to `./tls/` directory on your Mac host:
vagrant ssh -c "sudo cp -r /var/lib/boot2docker/tls `pwd`/"

export DOCKER_TLS_VERIFY="1"
export DOCKER_CERT_PATH="`pwd`/tls"
export DOCKER_HOST="tcp://`vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"`:2376"
```

### If TLS is disabled:
Use these commands to disable TLS for Docker daemon (you should do it
only once, after the initial `vagrant up`):

```
vagrant ssh -c "sudo sh -c 'echo \"export DOCKER_TLS=no\" > /var/lib/boot2docker/profile'"
vagrant reload
```

Now you just need to set `DOCKER_HOST` variable:
```
unset DOCKER_TLS_VERIFY
export DOCKER_HOST="tcp://`vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"`:2375"
```

That's it! Now your VM can be used as Docker host, check it:

```bash
docker version
...
```

## Shared Folders
`/Users` path on you Mac is shared with boot2docker VM by default. It means
that you can mount any directory placed in `/Users` on your Mac into the
container, for example:

```bash
docker run -v /Users/bob/myapp/src:/src [...]
```

If you want to mount any directory outside of `/Users`, then you should set it
(or its parent dir) as a synced folder in your Vagrantfile at first:

```ruby
config.vm.synced_folder "/tmp/dir_to_share", "/tmp/dir_to_share"
```

Refer to ["Synced Folders - Basic Usage"](https://docs.vagrantup.com/v2/synced-folders/basic_usage.html)
to get more details about synced folders in Vagrant.

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
