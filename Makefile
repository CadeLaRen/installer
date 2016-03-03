IMAGE:=ucp-install
CONTAINER:=$(IMAGE)-test

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
	docker build -t $(IMAGE) .
