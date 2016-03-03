IMAGE:=ucp-install
CONTAINER:=$(IMAGE)-test

uninstall: build
		#--pid host --uts host --ipc host --net host \
	docker run --rm -it \
		--name $(CONTAINER) \
		-v "/:/host" \
		$(IMAGE) uninstall

install: build
		#--pid host --uts host --ipc host --net host \
	docker run --rm -it \
		--name $(CONTAINER) \
		-v "/:/host" \
		$(IMAGE) 

ps:
	docker exec -it $(CONTAINER) ps aux

exec:
	docker exec -it $(CONTAINER) sh

sh: build
	docker run --rm -it \
		--pid host \
		--uts host \
		--ipc host \
		--net host \
		-v "/:/host" \
		$(IMAGE) sh

build:
	#docker pull $(shell grep FROM Dockerfile | sed "s/FROM//")
	docker build --pull -t $(IMAGE) .
