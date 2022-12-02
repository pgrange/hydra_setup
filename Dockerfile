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
# COPY --from=ghcr.io/input-output-hk/hydra-node:0.8.1 /bin/hydra-node /srv/hydra/
# COPY --from=ghcr.io/input-output-hk/hydra-tools:0.8.1 /bin/hydra-tools /srv/hydra/
# COPY --from=ghcr.io/input-output-hk/hydra-tui:0.8.1 /bin/hydra-tui /srv/hydra/
COPY --from=ghcr.io/input-output-hk/hydra-node@sha256:4cd4bbaebe2bc3c23943cddc6c0c62a745ef43a33c3feefd4022cb08aafb2873 /bin/hydra-node /srv/hydra/
COPY --from=ghcr.io/input-output-hk/hydra-tools@sha256:a0c9c2fd5816235133075ee4c98f3fcda9a5d506c63623b60d82237ea41fd271 /bin/hydra-tools /srv/hydra/
COPY --from=ghcr.io/input-output-hk/hydra-tui@sha256:e106702c3df144bcf594ac61c92216f327152a0f55c4b0a9535183427f11ea0a /bin/hydra-tui /srv/hydra/

ADD https://raw.githubusercontent.com/input-output-hk/hydra/master/hydra-cluster/config/protocol-parameters.json /srv/etc/hydra/

ENTRYPOINT [ "/srv/bin/run_hydra" ]
