#!/bin/bash

function createChannel {
    initOrdererVars "org0" 1
    initPeerVars $ORG $NO_PEER
    switchToAdminIdentity

    log "Creating channel '$CHANNEL_NAME' on $ORDERER_HOST ..."
    peer channel create --logging-level=DEBUG -c $CHANNEL_NAME -f $CHANNEL_TX_FILE -o $ORDERER_HOST:7050 --cafile $CA_CERTFILE
}

function installChaincode {
    initPeerVars "org0" "1"
    switchToAdminIdentity
    log "Installing chaincode on $PEER_HOST ..."

    peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric-samples/chaincode/abac/go
}

function updateAnchorPeer {
    initOrdererVars "org0" 1
    initPeerVars "org0" 1
    switchToAdminIdentity

    log "Updating anchor peers for $PEER_HOST ..."
    peer channel update -c $CHANNEL_NAME -f $ANCHOR_TX_FILE -o $ORDERER_HOST:7050 --cafile $CA_CERTFILE
}
function makeEndorsementPolicy {
    POLICY="OR('org0MSP.member')"

    log "policy: $POLICY"
}

function instantiateChaincode {
    makeEndorsementPolicy

    initOrdererVars "org0" 1
    initPeerVars "org0" 1
    switchToAdminIdentity

    log "Instantiating chaincode on $PEER_HOST ..."
    peer chaincode instantiate -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["Init","a","100","b","200"]}' -P "$POLICY" \
        -o $ORDERER_HOST:7050 --cafile $CA_CERTFILE

}

function chaincodeQuery {
    peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
}

function chaincodeInvoke {
    peer chaincode invoke -C mychannel -n mycc -c '{"Args":["invoke","a","b","10"]}' -o orderer1-org0:7050 --cafile /data/org0-ca-cert.pem
}