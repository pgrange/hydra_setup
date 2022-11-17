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
COPY --from=ghcr.io/input-output-hk/hydra-node:0.8.1 /bin/hydra-node /srv/hydra/
COPY --from=ghcr.io/input-output-hk/hydra-tools:0.8.1 /bin/hydra-tools /srv/hydra/
COPY --from=ghcr.io/input-output-hk/hydra-tui:0.8.1 /bin/hydra-tui /srv/hydra/
# COPY --from=ghcr.io/input-output-hk/hydra-node@sha256:74bd1509c5626005e68f78343ef728c638241649538c0f2f503ec122285e5c4d /bin/hydra-node /srv/hydra/
# COPY --from=ghcr.io/input-output-hk/hydra-tools@sha256:b0cd2ff21d4688d9acf04a5e43c86960a894d1ae353548facaa36cddf8e26f18 /bin/hydra-tools /srv/hydra/
# COPY --from=ghcr.io/input-output-hk/hydra-tui@sha256:fb6a32906cb699f46f3978e021dfe3c9e23e064041ad75ade5ae05bcdd5842c5 /bin/hydra-tui /srv/hydra/

#FIXME should get following data in another way
COPY --from=ghcr.io/pgrange/hydra_compilation:main /srv/hydra-poc/hydra-cluster/config/protocol-parameters.json /srv/etc/hydra/
ENV HYDRA_SCRIPTS_TX_ID=4081fab39728fa3c05c0edc4dc7c0e8c45129ca6b2b70bf8600c1203a79d2c6d

ENTRYPOINT [ "/srv/bin/run_hydra" ]
