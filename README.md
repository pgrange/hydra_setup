## Pre-requisites

You'll need [docker](https://docker.com) installed.

You'll need [GNU Make](https://www.gnu.org/software/make/).

## Run

To build the docker image and start the node:
 
```bash
#> make docker_run
```

This will build the docker image, create a docker volume to store persistent data and start
a new container from the image with the volume attached.

You should see cardano blockchain sync logs in the terminal.

## Use

To query the blockchain tip of our cardano-node:

```bash
#> docker exec -it hydra /srv/cardano/cardano-cli query tip --testnet-magic 1097911063
```
