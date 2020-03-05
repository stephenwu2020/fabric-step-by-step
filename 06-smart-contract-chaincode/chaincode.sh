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
  echo package...
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