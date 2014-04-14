boot2docker.box: boot2docker.iso template.json vagrantfile_virtualbox.tpl files/*
	packer build template.json

boot2docker.iso:
	curl -LO https://github.com/boot2docker/boot2docker/releases/download/v0.8.0/boot2docker.iso

test: test/Vagrantfile boot2docker.box
	vagrant box remove boot2docker
	vagrant box add boot2docker boot2docker.box
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

clean:
	rm -f boot2docker.iso
	rm -f *.box
	rm -rf output-*/

.PHONY: clean
