This will run a cardano-node for the preview network.

To get test Ada on the preview network see (select _preview_):
https://docs.cardano.org/cardano-testnet/tools/faucet

This wallet is pretty cool to quickly switch from cardano networks:
https://chrome.google.com/webstore/detail/nami/lpfcbjknijpeeillifnkikgncikgfhdo

# Pre-requisites

You'll need the following software on your machine:
* [docker](https://docker.com);
* [GNU Make](https://www.gnu.org/software/make/);
* [git](https://git-scm.com).

# Run

To run docker image, you'll need to attach volumes in some specific path:
```bash
  docker volume create cardano-db
  docker volume create reckless-secret-storage
  docker run --rm --name hydra \
             --mount 'type=volume,src=cardano-db,dst=/srv/var/cardano/db' \
             --mount 'type=volume,src=reckless-secret-storage,dst=/srv/var/cardano/secrets' \
             -it ghcr.io/pgrange/hydra_setup:compile_hydra
```

# Use

Your Cardano address to receive payments:

```bash
dump_address
```

Your Cardano verification key:

```bash
dump_verification_key
```

To query the blockchain tip of our cardano-node:

```bash
#> docker exec -it hydra /srv/cardano/cardano-cli query tip --testnet-magic 2
```

# Compile

To build the docker image and start the node (be patient, hydra-node compilation can take up to one or two hours):
 
```bash
#> make run
```

This will build the docker image, create a docker volume to store persistent data and start
a new container from the image with the volume attached.

You should see cardano blockchain sync logs in the terminal.

As of end of september 2022 the preview network it takes 10 minutes for a fresh cardano-node to be fully synchronized.
So for the sake of simplicity, we do not use [mithril](https://github.com/input-output-hk/mithril/tree/main/mithril-client)
for now and just do a full sync from scratch.


