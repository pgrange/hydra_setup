# Update cardano configurations from source
ifneq ( $(shell git submodule status | grep '^[-+]' -c), 0 )
  $(shell git submodule update --init)
endif


image: Dockerfile cardano-node.tar.gz
	docker build . -t pgrange_cardano-node

run: image volume
	docker run -p 3001:3001 --rm --name hydra \
	--mount 'type=volume,src=cardano-db,dst=/srv/var/cardano/db' \
	--mount 'type=volume,src=reckless-secret-storage,dst=/srv/var/cardano/secrets' \
	-it pgrange_cardano-node bash

cardano-node.tar.gz:
	curl https://hydra.iohk.io/build/16338142/download/1/cardano-node-1.35.0-linux.tar.gz -o cardano-node.tar.gz

volume:
	docker volume create cardano-db
	docker volume create reckless-secret-storage

clean:
	rm cardano-node.tar.gz

.phony: image volume run clean
