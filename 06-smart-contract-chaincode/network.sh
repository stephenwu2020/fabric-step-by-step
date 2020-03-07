#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
TAG="2.0.0"

function help(){
  echo "Usage: "
  echo "  network.sh <cmd>"
  echo "cmd: "
  echo "  - crypto"
  echo "  - genesis"
  echo "  - channeltx"
  echo "  - chaincode"
  echo "  - up"
  echo "  - down"
  echo "  - clear"
  echo "  - start"
  echo "  - end"
}

function genCrypto(){
  cryptogen generate --config=./crypto-config.yaml --output="organizations"
}

function genGenesis(){
  configtxgen -profile NC4 -channelID ordererchannel -outputBlock ./system-genesis-block/genesis.block
}

function genChanTx(){
  configtxgen -profile CC1 -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
}

function execChaincode(){
  docker exec cli scripts/chaincode.sh $1
}

function execChannel(){
  docker exec cli scripts/channel.sh $1
}

function networkUp(){
  IMAGE_TAG=$TAG docker-compose up -d
}

function networkDown(){
  IMAGE_TAG=$TAG docker-compose down
}

function clear(){
  rm -rf organizations system-genesis-block channel-artifacts
}

if [ "$MODE" == "crypto" ]; then
  genCrypto
elif [ "$MODE" == "genesis" ]; then
  genGenesis
elif [ "$MODE" == "channeltx" ]; then
  genChanTx
elif [ "$MODE" == "chaincode" ]; then
  execChaincode $2
elif [ "$MODE" == "channel" ]; then
  execChannel $2
elif [ "$MODE" == "up" ]; then
  networkUp
elif [ "$MODE" == "down" ]; then
  networkDown
elif [ "$MODE" == "clear" ]; then
  clear
elif [ "$MODE" == "start" ]; then
  genCrypto
  genGenesis
  genChanTx
  networkUp
  genChanTx
elif [ "$MODE" == "end" ]; then
  networkDown
  clear
else        
  help
  exit 1
fi
