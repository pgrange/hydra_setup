#!/usr/bin/env bash

# Fork off some amount of the UTxO owned by given signing key and mark the rest
# as fuel to be used by the hydra-node.

set -euo pipefail

set -x

function usage() {
    echo "Usage: $0 <amount in lovelace>"
    exit 1
}
[ ${#} -eq 1 ] || (echo "Wrong number of arguments" && usage)
amount=${1}

magic=1

addr="$(docker exec -it hydra cat /srv/var/cardano/secrets/payment.addr)"

utxo=$(docker exec -it hydra /srv/cardano/cardano-cli query utxo \
    --cardano-mode --epoch-slots 21600 \
    --mainnet \
    --address "${addr}" \
    --out-file /dev/stdout)

totalLovelace=$(echo ${utxo} | jq -r 'reduce .[] as $item (0; . + $item.value.lovelace)')
if [[ ${totalLovelace} -eq 0 ]]
then
  echo "Error: insufficient funds" >&2
  exit 1
fi

entries=$(echo ${utxo} | jq "to_entries|sort_by(.value.value.lovelace)|last")
input=$(echo ${entries} | jq '.key' | tr -d '"')
fuelAmount=$(echo ${entries} | jq ".value.value.lovelace - ${amount}")

tx=$(docker exec -it hydra mktemp)
docker exec -it hydra /srv/cardano/cardano-cli transaction build \
     --mainnet \
     --babbage-era \
     --cardano-mode --epoch-slots 21600 \
     --script-valid \
     --tx-in ${input} \
     --tx-out ${addr}+${fuelAmount} \
     --tx-out-datum-hash "a654fb60d21c1fed48db2c320aa6df9737ec0204c0ba53b9b94a09fb40e757f3" \
     --change-address ${addr} \
     --out-file ${tx}

docker exec -it hydra /srv/cardano/cardano-cli transaction sign \
     --mainnet \
     --tx-body-file ${tx} \
     --signing-key-file /srv/var/cardano/secrets/payment.skey \
     --out-file ${tx}.signed

docker exec -it hydra /srv/cardano/cardano-cli transaction submit \
    --cardano-mode \
    --epoch-slots 21600 \
    --mainnet \
    --tx-file ${tx}.signed
