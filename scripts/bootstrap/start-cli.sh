#!/bin/bash

function main {
    log "Start building channel artifacts ..."
    registerIdentities
    getCACerts
    makeConfigTxYaml
    generateChannelArtifacts
    log "Finished building channel artifacts!"
    touch /$SETUP_SUCCESS_FILE
}

function registerIdentities {
    initOrgVars "org0"
    enrollCAAdmin

    initOrdererVars "org0" "1"

    log "Registering $ORDERER_NAME with $CA_NAME"
    fabric-ca-client register -d --id.name $ORDERER_NAME --id.secret $ORDERER_PASS --id.type orderer

    log "Registering $ADMIN_NAME with $CA_NAME"
    fabric-ca-client register -d --id.name $ADMIN_NAME --id.secret $ADMIN_PASS --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"
}

function getCACerts {
    log "Getting CA certificates ..."
    initOrgVars $ORG

    log "Getting CA certs for organization $ORG and storing in $ORG_MSP_DIR"
    fabric-ca-client getcacert -d -u http://$CA_HOST:7054 -M $ORG_MSP_DIR

    # we need to enroll the admin now to populate the admincerts directory
    switchToAdminIdentity
}

function makeConfigTxYaml {
    cp /$DATA/configtx.yaml /etc/hyperledger/fabric
}

function generateChannelArtifacts() {
    which configtxgen
    if [ "$?" -ne 0 ]; then
        fatal "configtxgen tool not found. exiting"
    fi

    log "Generating orderer genesis block at $GENESIS_BLOCK_FILE"
    configtxgen -profile OrgOrdererGenesis -outputBlock $GENESIS_BLOCK_FILE
    if [ "$?" -ne 0 ]; then
        fatal "Failed to generate orderer genesis block"
    fi

    log "Generating channel configuration transaction at $CHANNEL_TX_FILE"
    configtxgen -profile OrgChannel -outputCreateChannelTx $CHANNEL_TX_FILE -channelID $CHANNEL_NAME
    if [ "$?" -ne 0 ]; then
        fatal "Failed to generate channel configuration transaction"
    fi

    initOrgVars $ORG
    log "Generating anchor peer update transaction for $ORG at $ANCHOR_TX_FILE"
    configtxgen -profile OrgChannel -outputAnchorPeersUpdate $ANCHOR_TX_FILE \
                 -channelID $CHANNEL_NAME -asOrg $ORG
    if [ "$?" -ne 0 ]; then
        fatal "Failed to generate anchor peer update for $ORG"
     fi
}

set -e

SDIR=$(dirname "$0")
source $SDIR/../env.sh
source $SDIR/../utils.sh

main