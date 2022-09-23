docker_image: Dockerfile cardano-node.tar.gz testnet-topology.json testnet-shelley-genesis.json testnet-config.json testnet-byron-genesis.json testnet-alonzo-genesis.json
	docker build . -t hydra_setup

cardano-node.tar.gz:
	curl https://hydra.iohk.io/build/16338142/download/1/cardano-node-1.35.0-linux.tar.gz -o cardano-node.tar.gz

testnet-topology.json:
	curl -O -J https://hydra.iohk.io/build/7654130/download/1/testnet-topology.json
testnet-shelley-genesis.json:
	curl -O -J https://hydra.iohk.io/build/7654130/download/1/testnet-shelley-genesis.json
testnet-config.json:
	curl -O -J https://hydra.iohk.io/build/7654130/download/1/testnet-config.json
testnet-byron-genesis.json:
	curl -O -J https://hydra.iohk.io/build/7654130/download/1/testnet-byron-genesis.json
testnet-alonzo-genesis.json:
	curl -O -J https://hydra.iohk.io/build/7654130/download/1/testnet-alonzo-genesis.json

docker_run: docker_image docker_volume
	docker run --name hydra --mount 'type=volume,src=cardano-db,dst=/srv/var/cardano/db' -it hydra_setup bash

docker_volume:
	docker volume create cardano-db

clean:
	rm cardano-node.tar.gz testnet-*.json

.phony: docker_image docker_volume docker_run clean
