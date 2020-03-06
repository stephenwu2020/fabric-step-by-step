#!/bin/bash

VERSION=2.0.0
TAG=2.0

# pull images
docker pull hyperledger/fabric-orderer:${VERSION}
docker pull hyperledger/fabric-peer:${VERSION}
docker pull hyperledger/fabric-tools:${VERSION}
docker pull hyperledger/fabric-ccenv:${VERSION}

# tag
docker tag hyperledger/fabric-ccenv:${VERSION} hyperledger/fabric-ccenv:${TAG}