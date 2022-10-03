# Update cardano configurations from source
ifneq ( $(shell git submodule status | grep '^[-+]' -c), 0 )
  $(shell git submodule update --init)
endif

build: build_dependencies
	docker build . -t pgrange_cardano-node

# We split build from its dependencies to ease github action integration
build_dependencies: Dockerfile cardano-node.tar.gz

run: build volume
	docker run -p 3001:3001 --rm --name hydra \
	--mount 'type=volume,src=cardano-db,dst=/srv/var/cardano/db' \
	--mount 'type=volume,src=reckless-secret-storage,dst=/srv/var/cardano/secrets' \
	--mount 'type=volume,src=hydra-peers,dst=/srv/etc/hydra/peers' \
	-it pgrange_cardano-node

cardano-node.tar.gz:
	curl https://hydra.iohk.io/build/16338142/download/1/cardano-node-1.35.0-linux.tar.gz -o cardano-node.tar.gz

volume:
	docker volume create cardano-db
	docker volume create reckless-secret-storage
	docker volume create hydra-peers

clean:
	rm cardano-node.tar.gz

.phony: build volume run clean build_dependencies
