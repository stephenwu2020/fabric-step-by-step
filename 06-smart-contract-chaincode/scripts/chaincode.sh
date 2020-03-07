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
  echo "install chaincode ..."
  GO111MODULE=on
  peer lifecycle chaincode install /opt/gopath/src/github.com/hyperledger/fabric/peer/pkg/mycc.tar.gz

  echo "install success:"
  peer lifecycle chaincode queryinstalled >&log.txt
  cat log.txt
  PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; $p;}' log.txt`
  echo PackageID is ${PACKAGE_ID}

  echo "approve ..."
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

if [ "$MODE" == "package" ]; then
  package
elif [ "$MODE" == "install" ]; then
  install
else        
  help
  exit 1
fi
