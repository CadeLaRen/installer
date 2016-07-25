
default: build push

update:
	docker deploy update.dsb update

build:
	docker build -t svendowideit/update-swarm-installer .

push:
	docker push svendowideit/update-swarm-installer


run:
	docker service rm update || true
	docker service create --name update --restart-condition=none --replicas=6 --mount source=/,target=/host,type=bind,writable=true svendowideit/update-swarm-installer
