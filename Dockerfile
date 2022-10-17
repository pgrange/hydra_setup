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
COPY --from=ghcr.io/pgrange/hydra_compilation:main /hydra-node /srv/hydra/
COPY --from=ghcr.io/pgrange/hydra_compilation:main /hydra-tools /srv/hydra/
COPY --from=ghcr.io/pgrange/hydra_compilation:main /hydra-tui /srv/hydra/
COPY --from=ghcr.io/pgrange/hydra_compilation:main /srv/hydra-poc/hydra-cluster/config/protocol-parameters.json /srv/etc/hydra/
COPY --from=ghcr.io/pgrange/hydra_compilation:main /COMMIT /srv/etc/hydra/
ENV HYDRA_SCRIPTS_TX_ID=bde2ca1f404200e78202ec37979174df9941e96fd35c05b3680d79465853a246

# hydra-node is not statically linked so we'll need those:
COPY --from=ghcr.io/pgrange/hydra_compilation:main /usr/local/lib/libsodium.so.23   /usr/local/lib/libsodium.so.23
COPY --from=ghcr.io/pgrange/hydra_compilation:main /usr/local/lib/libsecp256k1.so.0 /usr/local/lib/libsecp256k1.so.0
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# ---------------------------------------------------------------------

ENTRYPOINT [ "/srv/bin/run_hydra" ]
