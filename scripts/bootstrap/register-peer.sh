#!/bin/bash

set -e

SDIR=$(dirname "$0")

source $SDIR/../env.sh
source $SDIR/../utils.sh
source $SDIR/../peer.sh

function registerPeerIdentity {
    log "Beginning register new peer ..."

    initOrgVars $ORG
    enrollCAAdmin

    initPeerVars $ORG $NO_PEER

    log "Registering $PEER_NAME with $CA_NAME"
    fabric-ca-client register -d --id.name $PEER_NAME --id.secret $PEER_PASS --id.type peer

    log "Successfully register new peer!"
}

setupPeer
registerPeerIdentity
startPeer