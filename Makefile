all: boot2docker-virtualbox.box boot2docker-parallels.box

virtualbox: boot2docker-virtualbox.box

parallels: boot2docker-parallels.box

boot2docker-virtualbox.box: boot2docker.iso template.json vagrantfile.tpl files/*
	packer build -only virtualbox template.json

boot2docker-parallels.box: boot2docker.iso template.json vagrantfile.tpl files/*
	packer build -only parallels template.json

boot2docker.iso:
	curl -LO https://github.com/boot2docker/boot2docker/releases/download/v0.8.0/boot2docker.iso

test: test/Vagrantfile boot2docker-virtualbox.box
	vagrant box remove boot2docker --provider virtualbox
	vagrant box add boot2docker boot2docker-virtualbox.box
	cd test; \
	vagrant destroy -f; \
	vagrant up; \
	echo "-----> docker version"; \
	docker version; \
	echo "-----> docker images -t"; \
	docker images -t; \
	echo "-----> docker ps -a"; \
	docker ps -a; \
	vagrant suspend

ptest: test/Vagrantfile boot2docker-parallels.box
	vagrant box remove boot2docker --provider parallels
	vagrant box add boot2docker boot2docker-parallels.box
	cd test; \
	vagrant destroy -f; \
	vagrant up --provider parallels; \
	echo "-----> docker version"; \
	vagrant ssh -c "docker version"; \
	echo "-----> docker images -t"; \
	vagrant ssh -c "docker images -t"; \
	echo "-----> docker ps -a"; \
	vagrant ssh -c "docker ps -a"; \
	vagrant suspend

clean:
	rm -f boot2docker.iso
	rm -f boot2docker-virtualbox.box
	rm -f boot2docker-parallels.box
	rm -rf output-*/

.PHONY: clean
