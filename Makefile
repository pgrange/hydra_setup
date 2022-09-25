# Update cardano configurations from source
ifneq ( $(shell git submodule status | grep '^[-+]' -c), 0 )
  $(shell git submodule update --init)
endif

build: build_dependencies
	docker build . -t pgrange_cardano-node


# We split build from its dependencies to ease github action integration
build_dependencies: Dockerfile cardano-node.tar.gz ghcup_install

run: build volume
	docker run -p 3001:3001 --rm --name hydra \
	--mount 'type=volume,src=cardano-db,dst=/srv/var/cardano/db' \
	--mount 'type=volume,src=reckless-secret-storage,dst=/srv/var/cardano/secrets' \
	-it pgrange_cardano-node bash

cardano-node.tar.gz:
	curl https://hydra.iohk.io/build/16338142/download/1/cardano-node-1.35.0-linux.tar.gz -o cardano-node.tar.gz

ghcup_install:
	curl https://get-ghcup.haskell.org -o ghcup_install
	chmod +x ghcup_install

volume:
	docker volume create cardano-db
	docker volume create reckless-secret-storage

clean:
	rm cardano-node.tar.gz ghcup_install

.phony: image volume run clean docker_build_dependencies
