FROM debian:latest

# Install netbase to work around https://github.com/input-output-hk/cardano-node/issues/2752
RUN apt-get update && \
    apt-get install -y netbase jq && \
    rm -rf /var/lib/apt/lists/*

ADD cardano-node.tar.gz /srv/cardano
ADD cardano-configurations/network/preview \
    /srv/etc/cardano

ENV CARDANO_NODE_SOCKET_PATH=/srv/var/cardano/node.socket
ADD run_hydra /srv/bin/run_hydra

RUN mkdir -p /srv/var/cardano/

# ---------------------------------------------------------------------
# - install Hydra                                                     -
# ---------------------------------------------------------------------

RUN mkdir -p /srv/hydra
RUN mkdir -p /srv/etc/hydra
COPY hydra-node /srv/hydra/
COPY hydra-tools /srv/hydra/
COPY hydra-tui /srv/hydra/

ADD https://raw.githubusercontent.com/input-output-hk/hydra/master/hydra-cluster/config/protocol-parameters.json /srv/etc/hydra/

ENTRYPOINT [ "/srv/bin/run_hydra" ]
