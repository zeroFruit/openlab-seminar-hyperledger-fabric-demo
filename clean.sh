#!/bin/bash

set -e

echo "--- shutdown docker containers start ---"
docker rm $(docker ps -aq) -f
echo "--- shutdown docker containers done ---"

echo "--- setup start ---"
rm -R ./data/*
mkdir -p ./data/logs
mkdir -p ./data/ca
mkdir -p ./data/orderers
mkdir -p ./data/orgs
cp ./configtx.yaml ./data/
echo "--- setup done ---"

