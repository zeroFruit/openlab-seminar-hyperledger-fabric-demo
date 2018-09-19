#!/bin/bash

function setupPeer {
    log "Setup peer start"
    initPeerVars $ORG $NO_PEER

    PEER_TLS="$PEER_HOME/tls"
    PEER_MSP="$PEER_HOME/msp"

    mkdir -p $PEER_TLS
    mkdir -p $PEER_MSP

    log "Setup peer done"
}

function startPeer {
    # Enroll the peer to get an enrollment certificate and set up the core's local MSP directory
    fabric-ca-client enroll -d -u $ENROLLMENT_URL -M $CORE_PEER_MSPCONFIGPATH

    copyAdminCert $CORE_PEER_MSPCONFIGPATH

    # Start the peer
    log "Starting peer '$CORE_PEER_ID' with MSP at '$CORE_PEER_MSPCONFIGPATH'"
    env | grep CORE
    peer node start
}