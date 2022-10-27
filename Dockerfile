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
COPY --from=ghcr.io/input-output-hk/hydra-node@sha256:bfaaf20b2bdb02a3fdf9717354260918eb68f50dcc7ee7884ffa6b863376d794 /bin/hydra-node /srv/hydra/
COPY --from=ghcr.io/input-output-hk/hydra-tools@sha256:723e18e64a066fb2ac6ca30f07ea25e78d8a6c723ffd4a563f08fb91b63b4b9d /bin/hydra-tools /srv/hydra/
COPY --from=ghcr.io/input-output-hk/hydra-tui@sha256:75792ed8ca5dcfdbcb4da49e4ca50192c01ec03f6e4162df503733df31227487 /bin/hydra-tui /srv/hydra/

#FIXME should get following data in another way
COPY --from=ghcr.io/pgrange/hydra_compilation:main /srv/hydra-poc/hydra-cluster/config/protocol-parameters.json /srv/etc/hydra/
ENV HYDRA_SCRIPTS_TX_ID=bde2ca1f404200e78202ec37979174df9941e96fd35c05b3680d79465853a246

ENTRYPOINT [ "/srv/bin/run_hydra" ]
