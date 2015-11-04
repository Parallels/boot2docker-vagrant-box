#!/usr/bin/env bats

DOCKER_TARGET_VERSION=1.9.0

# Assume that Vagrantfile exists and basebox is added
@test "vagrant up" {
	run vagrant destroy -f
	run vagrant box remove boot2docker-virtualbox-test
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

@test "Default synced folder is shared via prl_fs" {
	mount_point=$(vagrant ssh -c 'mount' | grep prl_fs | awk '{ print $3 }')
	[ $(vagrant ssh -c "ls -l ${mount_point}/Vagrantfile | wc -l" -- -n -T) -ge 1 ]
}

@test "Rsync is installed in the VM" {
	vagrant ssh -c "which rsync"
}

@test "NFS client is running in the VM" {
	[ $(vagrant ssh -c 'ps aux | grep rpc.statd | wc -l' -- -n -T) -ge 1 ]
}

@test "Default synced folder is shared via NFS if B2D_NFS_SYNC is set" {
	export B2D_NFS_SYNC=1
	vagrant reload
	mount_point=$(vagrant ssh -c 'mount' | grep nfs | awk '{ print $3 }')
	[ $(vagrant ssh -c "ls -l $mount_point/Vagrantfile | wc -l" -- -n -T) -ge 1 ]
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
