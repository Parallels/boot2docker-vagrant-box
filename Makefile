boot2docker.box: boot2docker.iso template.json vagrantfile_virtualbox.tpl files/*
	packer build template.json

boot2docker.iso:
	curl -LO https://github.com/boot2docker/boot2docker/releases/download/v0.8.0/boot2docker.iso

clean:
	rm -f boot2docker.iso
	rm -f *.box
	rm -rf output-*/

.PHONY: clean
