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
