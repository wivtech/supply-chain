IMAGE ?= supply-chain-ui
IMAGE_DEV ?= $(IMAGE)-dev

DOCKER ?= docker                     # you can use "podman" as well
DOCKER_COMPOSE ?= docker-compose     # and "podman-compose" too

.PHONY: init
init:
	if [ -d "/tmp/wiv" ]; then sudo rm -rf /tmp/wiv; fi
	mkdir /tmp/wiv
	mkdir /tmp/wiv/{logs,keys,uploads}
	mkdir /tmp/wiv/{node,ipfs,db}
	@$(DOCKER_COMPOSE) -f stack.yml pull

.PHONY: start
start:
	@$(DOCKER_COMPOSE) -f stack.yml up

.PHONY: stop
stop:
	@$(DOCKER_COMPOSE) -f stack.yml down


.PHONY: release
release:
	@$(DOCKER) build --no-cache --squash -t $(IMAGE) .


.PHONY: dev-run-init
dev-init:
	yarn install

.PHONY: dev-run-db
dev-run-db:
	@$(DOCKER) run \
		--env MYSQL_ROOT_PASSWORD=Aszxqw1234 \
		--net=host -it --rm mariadb:10.5

.PHONY: dev-run-node
dev-run-node:
	@$(DOCKER) run --net=host -it --rm wivt/supply-chain:latest

.PHONY: dev-run-app
dev-run-app:
	node index.js

.PHONY: dev-docker-build
dev-docker-build:
	@$(DOCKER) build -t $(IMAGE_DEV) .

.PHONY: dev-docker-run
dev-docker-run:
	@$(DOCKER) run -v /tmp/wivkeys:/wivkeys:Z \
        -v /tmp/wivlogs:/wivlogs:Z \
        --net=host -it --rm \
        $(IMAGE_DEV)

.PHONY: dev-docker-inspect
dev-docker-inspect:
	@$(DOCKER) run --net=host -it --rm --entrypoint /bin/ash $(IMAGE_DEV)
