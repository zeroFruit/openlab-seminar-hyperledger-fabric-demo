#!/bin/bash

ORDERER_ORGS="org0"
DATA="data"
LOGDIR=$DATA/logs

# The path to the genesis block
GENESIS_BLOCK_FILE=/$DATA/genesis.block
# The path to a channel transaction
CHANNEL_TX_FILE=/$DATA/channel.tx
# Name of test channel
CHANNEL_NAME=mychannel

# Name of a the file to create when configtx is successful
SETUP_SUCCESS_FILE=${LOGDIR}/setup.successful

SETUP_LOGFILE=${LOGDIR}/setup.log


function initOrgVars {
    if [ $# -ne 1 ]; then
        echo "Usage: initOrgVars <ORG>"
        exit 1
    fi

    ORG=$1

    CA_NAME=ca-${ORG}
    CA_HOST=ca-${ORG}

    CA_CERTFILE=/${DATA}/${ORG}-ca-cert.pem
    CA_LOGFILE=/${LOGDIR}/${CA_NAME}.log

    CA_ADMIN_USER=ca-${ORG}-admin
    CA_ADMIN_PASS=ca-${ORG}-adminpw
    CA_ADMIN_USER_PASS=${CA_ADMIN_USER}:${CA_ADMIN_PASS}

    ANCHOR_TX_FILE=/${DATA}/orgs/${ORG}/anchors.tx

    ORG_MSP_ID=${ORG}MSP
    ORG_MSP_DIR=/${DATA}/orgs/${ORG}/msp

    ORG_ADMIN_HOME=/${DATA}/orgs/$ORG/admin
    ORG_ADMIN_CERT=/${ORG_MSP_DIR}/admincerts/cert.pem

    ADMIN_NAME=admin-${ORG}
    ADMIN_PASS=${ADMIN_NAME}pw
}

function initOrdererVars {
    if [ $# -ne 2 ]; then
        echo "Usage: initOrdererVars <ORG> <ID>"
        exit 1
    fi

    initOrgVars $1
    ID=$2

    ORDERER_HOST=orderer${ID}-${ORG}
    ORDERER_NAME=orderer${ID}-${ORG}
    ORDERER_PASS=${ORDERER_NAME}pw
    ORDERER_NAME_PASS=${ORDERER_NAME}:${ORDERER_PASS}

    HOME=/data/orderers

    export FABRIC_CA_CLIENT=$HOME
    export ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
    export ORDERER_GENERAL_GENESISMETHOD=file
    export ORDERER_GENERAL_GENESISFILE=$GENESIS_BLOCK_FILE
    export ORDERER_GENERAL_LOCALMSPID=$ORG_MSP_ID
    export ORDERER_GENERAL_LOCALMSPDIR=${HOME}/${ORDERER_NAME}/msp
}

function initPeerVars {
    if [ $# -ne 2 ]; then
        echo "Usage: initPeerVars <ORG> <ID>: $*"
        exit 1
    fi

    initOrgVars $1
    ID=$2

    PEER_HOST=peer${ID}-${ORG}
    PEER_NAME=peer${ID}-${ORG}
    PEER_PASS=${PEER_NAME}pw
    PEER_NAME_PASS=${PEER_NAME}:${PEER_PASS}
    PEER_LOGFILE=$LOGDIR/${PEER_NAME}.log
    HOME=/data/peers

    export FABRIC_CA_CLIENT=$HOME
    export CORE_PEER_ID=$PEER_HOST
    export CORE_PEER_ADDRESS=$PEER_HOST:7051
    export CORE_PEER_LOCALMSPID=$ORG_MSP_ID
    export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
    export CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=tutorials_basic
    export CORE_LOGGING_LEVEL=DEBUG
    export CORE_PEER_GOSSIP_USELEADERELECTION=true
    export CORE_PEER_GOSSIP_ORGLEADER=false
    export CORE_PEER_GOSSIP_EXTERNALENDPOINT=$PEER_HOST:7051
}