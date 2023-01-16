# Update cardano configurations from source
ifneq ( $(shell git submodule status | grep '^[-+]' -c), 0 )
  $(shell git submodule update --init)
endif

build: build_dependencies
	docker build . -t pgrange_cardano-node

# We split build from its dependencies to ease github action integration
build_dependencies: Dockerfile cardano-node.tar.gz hydra-node hydra-tui hydra-tools

run: build volume
	docker run -p 3001:3001 --rm --name hydra \
	--mount 'type=volume,src=cardano-db,dst=/srv/var/cardano/db' \
	--mount 'type=volume,src=hydra-db,dst=/srv/var/hydra/db' \
	--mount 'type=volume,src=reckless-secret-storage,dst=/srv/var/cardano/secrets' \
	--mount 'type=volume,src=hydra-peers,dst=/srv/etc/hydra/peers' \
	-it pgrange_cardano-node

cardano-node.tar.gz:
	curl https://update-cardano-mainnet.iohk.io/cardano-node-releases/cardano-node-1.35.4-linux.tar.gz -o cardano-node.tar.gz

hydra-node hydra-tools hydra-tui: hydra-x86_64-unknown-linux-musl.zip
	unzip -D $< $@
	touch $@
	chmod +x $@

hydra-x86_64-unknown-linux-musl.zip:
	curl --fail --location -o $@ https://github.com/input-output-hk/hydra/releases/download/0.8.1/hydra-x86_64-unknown-linux-musl.zip
	#curl --fail --location -o $@ -H "Authorization: token ${SOME_TOKEN_WITHOUT_PERMISSIONS}" https://api.github.com/repos/input-output-hk/hydra/actions/artifacts/513013021/zip

volume:
	docker volume create cardano-db
	docker volume create hydra-db
	docker volume create reckless-secret-storage
	docker volume create hydra-peers

clean:
	-rm cardano-node.tar.gz hydra-node hydra-tui hydra-tools hydra-x86_64-unknown-linux-musl.zip

.phony: build volume run clean build_dependencies
