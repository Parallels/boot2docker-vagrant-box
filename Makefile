BOOT2DOCKER_VERSION := 1.7.0

B2D_ISO_FILE := boot2docker.iso
B2D_ISO_URL := https://github.com/boot2docker/boot2docker/releases/download/v$(BOOT2DOCKER_VERSION)/boot2docker.iso
B2D_ISO_CHECKSUM := e52d0ec9b0433520232457f141c19d70

PRL_B2D_ISO_FILE := boot2docker-prl.iso
PRL_B2D_ISO_URL := https://github.com/Parallels/boot2docker/releases/download/v1.7.0-prl-tools/boot2docker.iso
PRL_B2D_ISO_CHECKSUM := 6b6e5ddb06ade5adcd31194674e49ce7

all: parallels virtualbox

virtualbox:	clean-virtualbox build-virtualbox test-virtualbox

parallels: clean-parallels build-parallels test-parallels

$(B2D_ISO_FILE):
	curl -L -o ${B2D_ISO_FILE} ${B2D_ISO_URL}

$(PRL_B2D_ISO_FILE):
	curl -L -o ${PRL_B2D_ISO_FILE} ${PRL_B2D_ISO_URL}

build-virtualbox: $(B2D_ISO_FILE)
	packer build -parallel=false -only=virtualbox-iso \
		-var 'B2D_ISO_FILE=${B2D_ISO_FILE}' \
		-var 'B2D_ISO_CHECKSUM=${B2D_ISO_CHECKSUM}' \
		template.json

build-parallels: $(PRL_B2D_ISO_FILE)
	packer build -parallel=false -only=parallels-iso \
		-var 'B2D_ISO_FILE=${PRL_B2D_ISO_FILE}' \
		-var 'B2D_ISO_CHECKSUM=${PRL_B2D_ISO_CHECKSUM}' \
		template.json

clean-virtualbox:
	rm -rf *_virtualbox.box $(B2D_ISO_FILE)

clean-parallels:
	rm -rf *_parallels.box $(PRL_B2D_ISO_FILE)

test-virtualbox:
	@cd tests/virtualbox; bats --tap *.bats

test-parallels:
	@cd tests/parallels; bats --tap *.bats

.PHONY: all virtualbox parallels \
	clean-virtualbox build-virtualbox test-virtualbox \
	clean-parallels build-parallels test-parallels
