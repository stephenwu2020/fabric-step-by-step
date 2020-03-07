#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/demo.com/orderers/o4.demo.com/msp/tlscacerts/tlsca.demo.com-cert.pem
TAG="2.0.0"

function help(){
  echo "Usage: "
  echo "  chaincode.sh <cmd>"
  echo "cmd: "
  echo "  - package"
  echo "  - install"
}

function package(){
  if [ -f "pkg/mycc.tar.gz" ]; then
    echo "pkg already exist"
  else
    echo "fetch go dependency"
    cd /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/abstore/go/
    go mod vendor

    echo "package chaincode"
    peer lifecycle chaincode package mycc.tar.gz \
      --path github.com/hyperledger/fabric-samples/chaincode/abstore/go/ \
      --lang golang \
      --label fabcar_1

    cp mycc.tar.gz /opt/gopath/src/github.com/hyperledger/fabric/peer/pkg
  fi
}

function install(){
  # install
  GO111MODULE=on
  peer lifecycle chaincode install /opt/gopath/src/github.com/hyperledger/fabric/peer/pkg/mycc.tar.gz

  # query
  peer lifecycle chaincode queryinstalled >&log.txt
  cat log.txt
  PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; $p;}' log.txt`
  echo PackageID is ${PACKAGE_ID}

  # approve
  peer lifecycle chaincode approveformyorg \
    --channelID $CHANNEL_NAME \
    --name mycc \
    --version 1.0 \
    --init-required \
    --package-id $PACKAGE_ID \
    --sequence 1 \
    --tls \
    --cafile $CAFILE
}

function checkcommitreadiness(){
  # checkcommitreadiness
  peer lifecycle chaincode checkcommitreadiness \
    --channelID $CHANNEL_NAME \
    --name mycc \
    --version 1.0 \
    --sequence 1 \
    --init-required \
    --output json
}

function invoke(){
  peer chaincode invoke \
    -o o4.demo.com:7050 \
    --isInit \
    --tls \
    --cafile $CAFILE \
    -C $CHANNEL_NAME \
    -n mycc \
    --peerAddresses peer0.r1.demo.com:7051 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/r1.demo.com/peers/peer0.r1.demo.com/tls/ca.crt \
    -c '{"Args":["Init","a","100","b","100"]}' \
    --waitForEvent
}

function query(){

}

if [ "$MODE" == "package" ]; then
  package
elif [ "$MODE" == "install" ]; then
  install
elif [ "$MODE" == "check" ]; then
  checkcommitreadiness
elif [ "$MODE" == "invoke" ]; then
  invoke
elif [ "$MODE" == "query" ]; then
  query
else        
  help
  exit 1
fi
