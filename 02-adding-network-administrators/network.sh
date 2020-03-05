#!/bin/bash

MODE=$1

function help(){
  echo "Usage: "
  echo "  network.sh <cmd>"
  echo "cmd: "
  echo "  - crypto"
  echo "  - genesis"
  echo "  - up"
  echo "  - down"
  echo "  - clear"
}

if [ "$MODE" == "crypto" ]; then
  cryptogen generate --config=./crypto-config.yaml --output="organizations"
elif [ "$MODE" == "genesis" ]; then
  configtxgen -profile NC4 -channelID ordererchannel -outputBlock ./system-genesis-block/genesis.block
elif [ "$MODE" == "up" ]; then
  docker-compose up -d
elif [ "$MODE" == "down" ]; then
  docker-compose down
elif [ "$MODE" == "clear" ]; then
  rm -rf organizations system-genesis-block
else        
  help
  exit 1
fi
