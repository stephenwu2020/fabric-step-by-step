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
  CC_SRC_PATH=/opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/abstore/go/
  CC_RUNTIME_LANGUAGE=golang
  VERSION=1
  docker exec \
    -e "CC_SRC_PATH=${CC_SRC_PATH}" \
    cli bash cd ${CC_SRC_PATH} go mod vendor \

  echo "package chaincode"
  docker exec \
    -e "CC_SRC_PATH=${CC_SRC_PATH}" \
    -e "CC_RUNTIME_LANGUAGE=${CC_RUNTIME_LANGUAGE}" \
    -e "VERSION=${VERSION}" \
    cli peer lifecycle chaincode package mycc.tar.gz \
    --path ${CC_SRC_PATH} \
    --lang ${CC_RUNTIME_LANGUAGE} \
    --label fabcar_${VERSION}
}

function install(){
  echo install...
}

if [ "$MODE" == "package" ]; then
  package
elif [ "$MODE" == "install" ]; then
  install
else        
  help
  exit 1
fi