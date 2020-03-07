#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/demo.com/orderers/o4.demo.com/msp/tlscacerts/tlsca.demo.com-cert.pem
TAG="2.0.0"

# r1 env
R1MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/r1.demo.com/users/Admin@r1.demo.com/msp
R1ADDR=peer0.r1.demo.com:7051
R1MSPID="R1"
R1CRT=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/r1.demo.com/peers/peer0.r1.demo.com/tls/ca.crt 

# r2 env
R2MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/r2.demo.com/users/Admin@r2.demo.com/msp
R2ADDR=peer0.r2.demo.com:8051
R2MSPID="R2"
R2CRT=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/r2.demo.com/peers/peer0.r2.demo.com/tls/ca.crt 

function help(){
  echo "Usage: "
  echo "  chaincode.sh <cmd>"
  echo "cmd: "
  echo "  - package"
  echo "  - install"
  echo "  - check"
  echo "  - invoke"
  echo "  - query"
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
  GO111MODULE=on

  # install on peer of r1
  CORE_PEER_MSPCONFIGPATH=${R1MSP}
  CORE_PEER_ADDRESS=${R1ADDR}
  CORE_PEER_LOCALMSPID=${R1MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R1CRT}
  peer lifecycle chaincode install /opt/gopath/src/github.com/hyperledger/fabric/peer/pkg/mycc.tar.gz

  # install on peer of r2
  CORE_PEER_MSPCONFIGPATH=${R2MSP}
  CORE_PEER_ADDRESS=${R2ADDR}
  CORE_PEER_LOCALMSPID=${R2MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R2CRT}
  peer lifecycle chaincode install /opt/gopath/src/github.com/hyperledger/fabric/peer/pkg/mycc.tar.gz

}

function approve(){
  # query
  peer lifecycle chaincode queryinstalled >&log.txt
  cat log.txt
  PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; $p;}' log.txt`
  echo PackageID is ${PACKAGE_ID}

  # approve r1
  CORE_PEER_MSPCONFIGPATH=${R1MSP}
  CORE_PEER_ADDRESS=${R1ADDR}
  CORE_PEER_LOCALMSPID=${R1MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R1CRT}
  peer lifecycle chaincode approveformyorg \
    --channelID $CHANNEL_NAME \
    --name mycc \
    --version 1.0 \
    --init-required \
    --package-id $PACKAGE_ID \
    --sequence 1 \
    --tls \
    --cafile $CAFILE


  # approve r2
  CORE_PEER_MSPCONFIGPATH=${R2MSP}
  CORE_PEER_ADDRESS=${R2ADDR}
  CORE_PEER_LOCALMSPID=${R2MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R2CRT}
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
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/r1.demo.com/peers/peer0.r1.demo.com/tls/ca.crt \
    -c '{"Args":["Init","a","100","b","100"]}' \
    --waitForEvent
}

function query(){
  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
}

if [ "$MODE" == "package" ]; then
  package
elif [ "$MODE" == "install" ]; then
  install
elif [ "$MODE" == "approve" ]; then
  approve
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
