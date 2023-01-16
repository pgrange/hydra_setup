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
COPY --from=ghcr.io/input-output-hk/hydra-node@sha256:d349100e79a920882d9ced16779dff4ad551eae9d46b7395db41bf1c89b0387a /bin/hydra-node /srv/hydra/
COPY --from=ghcr.io/input-output-hk/hydra-tools@sha256:4466af7cd8835927d3719128fe49822b45df30b53fcbfb43d3b11d96c9df3cc1 /bin/hydra-tools /srv/hydra/
COPY --from=ghcr.io/input-output-hk/hydra-tui@sha256:d8eceef542b7f7f23287686abec1fd3c946466e9b5bf484babd9543a801aab20 /bin/hydra-tui /srv/hydra/

ADD https://raw.githubusercontent.com/input-output-hk/hydra/master/hydra-cluster/config/protocol-parameters.json /srv/etc/hydra/

ENTRYPOINT [ "/srv/bin/run_hydra" ]
