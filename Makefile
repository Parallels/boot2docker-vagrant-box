BOOT2DOCKER_VERSION := 17.03.1-ce

B2D_ISO_FILE := boot2docker.iso
B2D_ISO_URL := https://github.com/boot2docker/boot2docker/releases/download/v$(BOOT2DOCKER_VERSION)/boot2docker.iso
B2D_ISO_CHECKSUM := 85f1947876c0f02e4dfbab838cc18d9b

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
