#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
FABRIC_CFG_PATH=$PWD
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
  echo "fetch go dependency"
  docker exec cli bash \
    -c "cd /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/abstore/go/ && go mod vendor"

  echo "package chaincode"
  docker exec \
    cli peer lifecycle chaincode package mycc.tar.gz \
    --path github.com/hyperledger/fabric-samples/chaincode/abstore/go/ \
    --lang golang \
    --label fabcar_1
}

function install(){
  echo "install..."
  docker exec -e "GO111MODULE=on" cli peer lifecycle chaincode install mycc.tar.gz
}

if [ "$MODE" == "package" ]; then
  package
elif [ "$MODE" == "install" ]; then
  install
else        
  help
  exit 1
fi