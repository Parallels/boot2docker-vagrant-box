BOOT2DOCKER_VERSION := 17.06.0-ce

B2D_ISO_FILE := boot2docker.iso
B2D_ISO_URL := https://github.com/boot2docker/boot2docker/releases/download/v$(BOOT2DOCKER_VERSION)/boot2docker.iso
B2D_ISO_CHECKSUM := 5be6a9a57876b57b056cc640fa7b8534

default: parallels

parallels: clean-parallels build-parallels test-parallels

$(B2D_ISO_FILE):
	curl -L -o ${B2D_ISO_FILE} ${B2D_ISO_URL}

$(PRL_B2D_ISO_FILE):
	curl -L -o ${PRL_B2D_ISO_FILE} ${PRL_B2D_ISO_URL}

build-parallels: $(B2D_ISO_FILE)
	packer build -parallel=false -only=parallels-iso \
		-var 'B2D_ISO_FILE=${B2D_ISO_FILE}' \
		-var 'B2D_ISO_CHECKSUM=${B2D_ISO_CHECKSUM}' \
		template.json

clean-parallels:
	rm -f *-parallels.box $(B2D_ISO_FILE)
	@cd ./tests; vagrant destroy -f || :
	@cd ./tests; rm -f Vagrantfile

test-parallels:
	@cd ./tests; bats --tap *.bats

.PHONY: parallels clean clean-parallels build-parallels test-parallels
