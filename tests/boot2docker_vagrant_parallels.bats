#!/usr/bin/env bats

DOCKER_TARGET_VERSION=17.03.1-ce

# Assume that Vagrantfile exists and basebox is added
@test "vagrant up" {
	run vagrant destroy -f
	run vagrant box remove boot2docker-parallels-test
	cp vagrantfile.orig Vagrantfile
	vagrant up --provider=parallels
}

@test "vagrant ssh" {
	vagrant ssh -c 'echo OK'
}

@test "Default ssh user has sudoers rights" {
	[ "$(vagrant ssh -c 'sudo whoami' -- -n -T)" == "root" ]
}

@test "Docker client exists in the remote VM" {
	vagrant ssh -c 'which docker'
}

@test "Docker is working inside the remote VM " {
	vagrant ssh -c 'docker ps'
}

@test "Docker version is ${DOCKER_TARGET_VERSION}" {
	DOCKER_VERSION=$(vagrant ssh -c "docker version --format '{{.Server.Version}}'" -- -n -T)
	[ "${DOCKER_VERSION}" == "${DOCKER_TARGET_VERSION}" ]
}

@test "Custom bootlocal.sh script has been run at boot" {
	[ $(vagrant ssh -c 'grep OK /tmp/token-boot-local | wc -l' -- -n -T) -eq 1 ]
}

@test "vagrant reload" {
	vagrant reload
}

@test "'/Users' and '.' synced folders are shared via prl_fs" {
	run vagrant ssh -c 'mount | grep prl_fs'
  [ "$status" -eq 0  ]
  [ "${#lines[@]}" -ge 2 ]
  run vagrant ssh -c "ls -l /vagrant/Vagrantfile"
  [ "$status" -eq 0  ]
}

@test "NFS client is running in the VM" {
	[ $(vagrant ssh -c 'ps aux | grep rpc.statd | wc -l' -- -n -T) -ge 1 ]
}

@test "Reload VM with enabled B2D_NFS_SYNC" {
	export B2D_NFS_SYNC=1
	run vagrant reload
}

@test "'/Users' synced folder is shared via NFS" {
	run vagrant ssh -c "mount | grep '/Users.*nfs'"
  [ "$status" -eq 0  ]
  [ "${#lines[@]}" -ge 1 ]
  unset B2D_NFS_SYNC
}

@test "Default synced folder can be shared via rsync" {
	sed 's/#SYNC_TOKEN/config.vm.synced_folder ".", "\/vagrant", type: "rsync"/g' vagrantfile.orig > Vagrantfile
	vagrant reload
	[ $( vagrant status | grep 'running' | wc -l ) -ge 1 ]
	vagrant ssh -c "ls -l /vagrant/Vagrantfile"
}

@test "vagrant halt" {
	vagrant halt
}

@test "destroy and cleanup" {
	vagrant destroy -f
	vagrant box remove boot2docker-parallels-test
}
