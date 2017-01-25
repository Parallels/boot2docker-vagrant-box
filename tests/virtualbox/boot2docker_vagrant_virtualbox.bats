#!/usr/bin/env bats

# Given i'm already in a Vagrantfile-ized folder
# And the basebox has already been added to vagrant

DOCKER_TARGET_VERSION=1.13.0

@test "We can vagrant up the VM with basic settings" {
	# Ensure the VM is stopped
	run vagrant destroy -f
	run vagrant box remove boot2docker-virtualbox-test
	cp vagrantfile.orig Vagrantfile
	vagrant up --provider=virtualbox
	[ $( vagrant status | grep 'running' | wc -l ) -ge 1 ]
}

@test "Vagrant can ssh to the VM" {
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

@test "Docker is version DOCKER_TARGET_VERSION=${DOCKER_TARGET_VERSION}" {
	DOCKER_VERSION=$(vagrant ssh -c "docker version --format '{{.Server.Version}}'" -- -n -T)
	[ "${DOCKER_VERSION}" == "${DOCKER_TARGET_VERSION}" ]
}

@test "My bootlocal.sh script, should have been run at boot" {
	[ $(vagrant ssh -c 'grep OK /tmp/token-boot-local | wc -l' -- -n -T) -eq 1 ]
}

@test "We can reboot the VM properly" {
	vagrant reload
	vagrant ssh -c 'echo OK'
}

@test "'/Users' and '.' synced folders are shared via vboxsf" {
	run vagrant ssh -c 'mount | grep vboxsf'
	[ "$status" -eq 0  ]
	[ "${#lines[@]}" -ge 2 ]
	run vagrant ssh -c "ls -l /vagrant/Vagrantfile"
	[ "$status" -eq 0  ]
}

@test "The NFS client is started inside the VM" {
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

@test "We can disable the private network if B2D_DISABLE_PRIVATE_NETWORK is set" {
	export B2D_DISABLE_PRIVATE_NETWORK=1
	vagrant reload
	[ $(vagrant ssh -c "ip addr show | grep -e 'eth.:' | wc -l" -- -n -T) -eq 1 ]
	unset B2D_DISABLE_PRIVATE_NETWORK
}

@test "We can share folder thru rsync" {
	sed 's/#SYNC_TOKEN/config.vm.synced_folder ".", "\/vagrant", type: "rsync"/g' vagrantfile.orig > Vagrantfile
	vagrant reload
	[ $( vagrant status | grep 'running' | wc -l ) -ge 1 ]
	vagrant ssh -c "ls -l /vagrant/Vagrantfile"
}

@test "I can stop the VM" {
	vagrant halt
}

@test "I can destroy and clean the VM" {
	vagrant destroy -f
	vagrant box remove boot2docker-virtualbox-test
}
