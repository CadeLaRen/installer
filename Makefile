.PHONY: install

IMAGE:=ucp-install
CONTAINER:=$(IMAGE)-test

# any target not explicitly listed is passed to the container run
# WARNING, this does break target chaining
%: % 
	docker run --rm -it \
		--name $(CONTAINER) \
		-v "/:/host" \
		$(IMAGE) $@

build:
	docker build --pull -t $(IMAGE) .

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


