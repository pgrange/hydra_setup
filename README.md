**This is for test only**

Do not use any of the following code, commands or tools to handle actual funds
on the production network.

This will run a cardano-node for the preview network and a hydra-node on top of it.

To get test Ada on the preview network see (select _preview_):
https://docs.cardano.org/cardano-testnet/tools/faucet

Since you need a wallet to receive fund and then play on top of Cardano,
I found the [Nami](https://chrome.google.com/webstore/detail/nami/lpfcbjknijpeeillifnkikgncikgfhdo)
wallet pretty cool as it is easy to use and allow to switch quickly between cardano test networks.

# Run

## Pre-requisites

You'll need [docker](https://docker.com) on your machine.
To run docker image, you'll need to create several persistent volumes:

```bash
docker volume create cardano-db
docker volume create hydra-db
docker volume create reckless-secret-storage
docker volume create hydra-peers
```

## Start the node

Launch a container, attaching these volumes where appropriate:

```bash
docker run --rm --name hydra \
           --mount 'type=volume,src=cardano-db,dst=/srv/var/cardano/db' \
           --mount 'type=volume,src=hydra-db,dst=/srv/var/hydra/db' \
           --mount 'type=volume,src=reckless-secret-storage,dst=/srv/var/cardano/secrets' \
           --mount 'type=volume,src=hydra-peers,dst=/srv/etc/hydra/peers' \
           --expose 5001 \
           -it ghcr.io/pgrange/hydra_setup:latest
```

The first time you launch the container, it will generate cardano keys and address and hydra keys.
These informations will be displayed when you launch the container so that you may copy them and share
them with your friends you want to create a hydra head with. This will look like this:

```
# my Cardano versification key
cat << EOF >my-cardano-key.vk
{
    "type": "PaymentVerificationKeyShelley_ed25519",
    "description": "Payment Verification Key",
    "cborHex": "58208e16ebbd6d76b7e620dc3d56e39e5416869559a89558b1c716656864ed29be68"
}
EOF

# my Cardano address
cat << EOF >my-cardano.addr
addr_test1vq7xfu08xt2qqlfgt2rxm66xncus9qy0ecg329n4pm9z55s94wac4
EOF

# my Hydra verification key
echo 'd9QPt7PgxQoWkJtlcWXI77J9gDdF7Fv/HlGzaasyMlk=' | base64 -d > my-hydra-key.vk
```

## Meet some friends

You will then need to setup configuration for your peers you want to open
your hydra head with.

You don't have to do that know, you may skip that for now and come back to this
section later.

To do so, you may attach to your running container and setup
configuration:

```bash
docker exec -it hydra bash
```
Peer configuration must be added in `/srv/etc/hydra/peers/`.
Create one directory per peer, named after the peers' name.
Do not store anything else in this directory

In a peer directory, store the following three files:
 * ip         - contain ip:port address of the peer
 * cardano.vk - contains the cardano verification key of the peer
 * hydra.vk   - contains the hydra verification key of the peer

# Use

To query the blockchain tip of our cardano-node to see if it has finished syncronizing:

```bash
docker exec -it hydra /srv/cardano/cardano-cli query tip --testnet-magic 2
```

To inspect the utxo from your cardano address:

```bash
docker exec -it hydra bash -c '/srv/cardano/cardano-cli query utxo --address $(cat /srv/var/cardano/secrets/payment.addr) --testnet-magic 2'
```

You'll need to send test Ada to your address on this node. See 
https://docs.cardano.org/cardano-testnet/tools/faucet

When you have send funds to your cardano-node address, you will have to mark it as
hydra fuel before using it in a head. To do so, you can use the fuel-testnet.sh script
available in the repository (launch it from outside your container):

```bash
./utils/fuel-testnet.sh 90000000
```

This will mark 90 test Ada as fuel for hydra. I'm not sure what the appropriate amount is but 90
looks like a safe minimum for testing.

# Compile

## Pre-requisites

You'll need the following software on your machine:
* [GNU Make](https://www.gnu.org/software/make/);
* [git](https://git-scm.com).

To build the docker image and start the node (be patient, hydra-node compilation can take up to one or two hours):
 
```bash
make run
```

This will build the docker image, create the docker volumes needed to store persistent data and start
a new container from the image with the volumes attached.

You should see cardano blockchain sync logs and hydra logs in the terminal.

Warning! It depends on [hydra_compilation image](https://github.com/pgrange/hydra_compilation) so if you need to change something with the hydra code per se, you'll
have to take a look at this image.

As of end of september 2022 the preview network takes 10 minutes for a fresh cardano-node to be fully synchronized.
So for the sake of simplicity, we do not use [mithril](https://github.com/input-output-hk/mithril/tree/main/mithril-client)
for now and just do a full sync from scratch.
