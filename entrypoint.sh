#!/bin/bash

export AKASH_HOME="${PWD?}"
export AKASH_NET="https://raw.githubusercontent.com/ovrclk/net/master/$AKASH_NETWORK"
export AKASH_VERSION="$(curl -s "$AKASH_NET/version.txt")"
export AKASH_CHAIN_ID="$(curl -s "$AKASH_NET/chain-id.txt")"
export AKASH_SEEDS="${AKASH_SEEDS:-$(curl -s "$AKASH_NET/seed-nodes.txt" | paste -sd ",")}"

export AKASH_P2P_SEEDS=$AKASH_SEEDS
export AKASH_P2P_PERSISTENT_PEERS=$AKASH_SEEDS

export AKASH_RPC_LADDR="${AKASH_RPC_LADDR:-tcp://0.0.0.0:26657}"
export AKASH_FASTSYNC_VERSION="${AKASH_FASTSYNC_VERSION:v2}"
export AKASH_MINIMUM_GAS_PRICES="${AKASH_MINIMUM_GAS_PRICES:0.025uakt}"

akash init --chain-id "$AKASH_CHAIN_ID" "$AKASH_MONIKER"

curl -s "$AKASH_NET/genesis.json" > $AKASH_HOME/config/genesis.json

akash validate-genesis

if [ $BOOTSTRAP == "1" ]
then
  rm -rf ~/.akash/data;
  mkdir -p ~/.akash/data;
  cd ~/.akash/data
  if [[ -z "${SNAPSHOT_URL}" ]]; then
    SNAPSHOT_URL=http://rpc01-skynet.paullovette.com/akash/$(curl -s http://rpc01-skynet.paullovette.com/akash/ | egrep -o ">akashnet-2.*tar" | tr -d ">");
  fi

  echo "Downloading snapshot from $SNAPSHOT_URL..."
  wget -nv -O - $SNAPSHOT_URL | tar xf -
fi

exec "$@"
