#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
OTHER_CHANNEL_NAME="c2"
TAG="2.0.0"
FABRIC_CFG_PATH=$PWD

function help(){
  echo "Usage: "
  echo "  network.sh <cmd>"
  echo "cmd: "
  echo "  - crypto"
  echo "  - genesis"
  echo "  - channeltx"
  echo "  - up"
  echo "  - down"
  echo "  - clear"
  echo "  - start"
}

function genCrypto(){
  cryptogen generate --config=./crypto-config.yaml --output="organizations"
}

function genGenesis(){
  configtxgen -profile NC4 -channelID ordererchannel -outputBlock ./system-genesis-block/genesis.block
}

function genChanTx(){
  # channel tx
  configtxgen -profile CC1 -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
  # r1 anchor tx
  configtxgen -profile CC1 \
    -outputAnchorPeersUpdate ./channel-artifacts/R1MSPanchors.tx \
    -channelID $CHANNEL_NAME \
    -asOrg R1
  # r2 anchor tx
  configtxgen -profile CC1 \
    -outputAnchorPeersUpdate ./channel-artifacts/R2MSPanchors.tx \
    -channelID $CHANNEL_NAME \
    -asOrg R2

  # other channel 
  configtxgen -profile CC2 -outputCreateChannelTx ./channel-artifacts/${OTHER_CHANNEL_NAME}.tx -channelID ${OTHER_CHANNEL_NAME}
}

function networkUp(){
  IMAGE_TAG=$TAG docker-compose up -d
}

function networkDown(){
  IMAGE_TAG=$TAG docker-compose down
}

function clear(){
  rm -rf organizations system-genesis-block channel-artifacts
  docker rm -f $(docker ps -qa) 
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
else        
  help
  exit 1
fi
