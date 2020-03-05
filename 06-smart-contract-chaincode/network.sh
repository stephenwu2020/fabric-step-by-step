#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
FABRIC_CFG_PATH=$PWD
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/demo.com/orderers/o4.demo.com/msp/tlscacerts/tlsca.demo.com-cert.pem
TAG="2.0.0"

function help(){
  echo "Usage: "
  echo "  network.sh <cmd>"
  echo "cmd: "
  echo "  - crypto"
  echo "  - genesis"
  echo "  - channeltx"
  echo "  - channel"
  echo "  - anchor"
  echo "  - channelinfo"
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

function createChan(){
  docker exec \
    #-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/r1.demo.com/users/Admin@r1.demo.com/msp" \
    #peer0.r1.demo.com peer channel create \
    cli peer channel create \
    -o o4.demo.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.tx \
    --outputBlock /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.block \
    --tls \
    --cafile $CAFILE
}

function joinChan(){
  # join
  docker exec \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/r1.demo.com/users/Admin@r1.demo.com/msp" \
    peer0.r1.demo.com peer channel join \
    -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.block
  # show info
  showChanInfo
}

function showChanInfo(){
  docker exec peer0.r1.demo.com peer channel list
  docker exec peer0.r1.demo.com peer channel getinfo -c ${CHANNEL_NAME}
}

function setAnchor(){
  # anchor tx
  configtxgen -profile CC1 \
    -outputAnchorPeersUpdate ./channel-artifacts/R1MSPanchors.tx \
    -channelID $CHANNEL_NAME \
    -asOrg R1
  # anchor update
  docker exec \
    -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/r1.demo.com/users/Admin@r1.demo.com/msp" \
    peer0.r1.demo.com peer channel update \
    -o o4.demo.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/R1MSPanchors.tx \
    --tls \
    --cafile $CAFILE
  # show info
  showChanInfo
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
elif [ "$MODE" == "channel" ]; then
  createChan    
elif [ "$MODE" == "join" ]; then
  joinChan
elif [ "$MODE" == "anchor" ]; then
  setAnchor
elif [ "$MODE" == "channelinfo" ]; then
  showChanInfo
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
  echo "waiting orderer init for 5 second ..."
  sleep 5
  createChan
  joinChan
  setAnchor
elif [ "$MODE" == "end" ]; then
  networkDown
  clear
else        
  help
  exit 1
fi
