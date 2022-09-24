# Update cardano configurations from source
ifneq ( $(shell git submodule status | grep '^[-+]' -c), 0 )
  $(shell git submodule update --init)
endif


image: Dockerfile cardano-node.tar.gz
	docker build . -t pgrange_cardano-node

run: image volume
	docker run --rm --name hydra --mount 'type=volume,src=cardano-db,dst=/srv/var/cardano/db' -it pgrange_cardano-node bash

cardano-node.tar.gz:
	curl https://hydra.iohk.io/build/16338142/download/1/cardano-node-1.35.0-linux.tar.gz -o cardano-node.tar.gz

volume:
	docker volume create cardano-db

clean:
	rm cardano-node.tar.gz

.phony: image volume run clean
