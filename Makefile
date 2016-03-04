IMAGE:=install
CONTAINER:=$(IMAGE)-test

%: %
		#--pid host --uts host --ipc host --net host \
	docker run --rm -it \
		--name $(CONTAINER) \
		-v "/:/host" \
		$(IMAGE) $@

ps:
	docker exec -it $(CONTAINER) ps aux

exec:
	docker exec -it $(CONTAINER) sh

sh:
	docker run --rm -it \
		--pid host \
		--uts host \
		--ipc host \
		--net host \
		-v "/:/host" \
		--entrypoint sh \
		$(IMAGE)

build:
	docker build --pull -t $(IMAGE) .

hub:
	docker run --rm -it \
		--name $(CONTAINER) \
		-v "/:/host" \
			svendowideit/installer
