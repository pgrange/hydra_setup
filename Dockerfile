FROM debian:latest

#Work around https://github.com/input-output-hk/cardano-node/issues/2752
RUN apt-get update && \
    apt-get install -y netbase && \
    rm -rf /var/lib/apt/lists/*

ADD cardano-node.tar.gz /srv/cardano
ADD testnet-topology.json \
    testnet-shelley-genesis.json \
    testnet-config.json \
    testnet-byron-genesis.json \
    testnet-alonzo-genesis.json \
    /srv/etc/cardano/

ENV CARDANO_NODE_SOCKET_PATH=/srv/var/cardano/node.socket
ADD run_hydra /srv/bin/run_hydra

#TODO volume for data storage

# FIXME REMOVE debug
RUN apt update -y && apt install -y procps vim
# FIXME REMOVE debug

RUN mkdir -p /srv/var/cardano/

ENTRYPOINT [ "/srv/bin/run_hydra" ]
