#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
FABRIC_CFG_PATH=$PWD
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/demo.com/orderers/o4.demo.com/msp/tlscacerts/tlsca.demo.com-cert.pem

function help(){
  echo "Usage: "
  echo "  network.sh <cmd>"
  echo "cmd: "
  echo "  - crypto"
  echo "  - genesis"
  echo "  - channeltx"
  echo "  - channel"
  echo "  - up"
  echo "  - down"
  echo "  - clear"
}

if [ "$MODE" == "crypto" ]; then
  cryptogen generate --config=./crypto-config.yaml --output="organizations"
elif [ "$MODE" == "genesis" ]; then
  configtxgen -profile NC4 -channelID ordererchannel -outputBlock ./system-genesis-block/genesis.block
elif [ "$MODE" == "channeltx" ]; then
  configtxgen -profile CC1 -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
elif [ "$MODE" == "channel" ]; then
  docker exec cli peer channel create \
    -o o4.demo.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.tx \
    --tls true \
    --cafile $CAFILE
    
elif [ "$MODE" == "up" ]; then
  docker-compose up -d
elif [ "$MODE" == "down" ]; then
  docker-compose down
elif [ "$MODE" == "clear" ]; then
  rm -rf organizations system-genesis-block channel-artifacts
else        
  help
  exit 1
fi
