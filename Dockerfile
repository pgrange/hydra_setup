FROM debian:latest as compilation

RUN apt-get update  -y && \
    apt-get install -y \
      automake \
      autoconf \
      build-essential \
      pkg-config \
      libffi-dev \
      libgmp-dev \
      libssl-dev \
      libtinfo-dev \
      libsystemd-dev \
      zlib1g-dev \
      make \
      g++ \
      git \
      curl \
      tmux jq wget libncursesw5 libtool && \
    rm -rf /var/lib/apt/lists/*

# libsodium
RUN git clone https://github.com/input-output-hk/libsodium /srv/libsodium
WORKDIR /srv/libsodium
RUN git checkout 66f017f1 && \
   ./autogen.sh           && \
   ./configure            && \
   make                   && \
   make install
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# p256k1
RUN git clone https://github.com/bitcoin-core/secp256k1 /srv/secp256k1
WORKDIR /srv/secp256k1
RUN git checkout ac83be33 && \
    ./autogen.sh          && \
    ./configure --enable-module-schnorrsig --enable-experimental && \
    make                  && \
    make check            && \
    make install 

# install ghc-8.10.7 and cabal-3.6.0.2
# we do not use docker image haskell:8.10.7-buster because it relies
# on cabal version 3.8.1.0 and hydra-poc does not compile with this
# version. See https://github.com/haskell/cabal/issues/8422
RUN mkdir /srv/var /srv/bin
ENV PATH=/srv/bin/:$PATH
ADD ghcup_install /srv/bin
RUN BOOTSTRAP_HASKELL_NONINTERACTIVE=yes \
    BOOTSTRAP_HASKELL_NO_UPGRADE=yes \
    GHCUP_USE_XDG_DIRS=yes \
    BOOTSTRAP_HASKELL_GHC_VERSION=8.10.7 \
    XDG_DATA_HOME=/srv/var \
    XDG_BIN_HOME=/srv/bin \
    BOOTSTRAP_HASKELL_CABAL_VERSION=3.6.2.0 \
    BOOTSTRAP_HASKELL_ADJUST_BASHRC=yes \
    ghcup_install

# compile hydra-poc

RUN mkdir -p /srv/
RUN git clone https://github.com/input-output-hk/hydra-poc.git /srv/hydra-poc
WORKDIR /srv/hydra-poc
RUN git checkout 0.7.0

RUN cabal configure
RUN cabal update
RUN cabal build hydra-node
# TODO hydra-tools is not yet available in stable version 0.7.0
#      we should directly compile from master above and not 0.7.0
#      just keeping it that way to benefit from docker cache on my
#      machine and save 2 hours of compilation
RUN git switch master
RUN cabal build hydra-tools

# Make the following binaries available:
# * /hydra-node
# * /hydra-tools
RUN find dist-newstyle/ -type f -executable -name hydra-node -exec cp {} / \;
RUN find dist-newstyle/ -type f -executable -name hydra-tools -exec cp {} / \;

# ---------------------------------------------------------------------
# - install Cardano                                                   -
# ---------------------------------------------------------------------

FROM debian:latest

#Work around https://github.com/input-output-hk/cardano-node/issues/2752
RUN apt-get update && \
    apt-get install -y netbase && \
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
COPY --from=compilation /hydra-node /srv/hydra/
COPY --from=compilation /hydra-tools /srv/hydra/
COPY --from=compilation /srv/hydra-poc/hydra-cluster/config/protocol-parameters.json /srv/etc/hydra/
ENV HYDRA_SCRIPTS_TX_ID=bde2ca1f404200e78202ec37979174df9941e96fd35c05b3680d79465853a246

# hydra-node is not statically linked so we'll need those:
COPY --from=compilation /usr/local/lib/libsodium.so.23   /usr/local/lib/libsodium.so.23
COPY --from=compilation /usr/local/lib/libsecp256k1.so.0 /usr/local/lib/libsecp256k1.so.0
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# ---------------------------------------------------------------------

ENTRYPOINT [ "/srv/bin/run_hydra" ]
