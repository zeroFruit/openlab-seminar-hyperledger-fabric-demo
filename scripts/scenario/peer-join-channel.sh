#!/bin/bash

docker exec -it --env CORE_PEER_MSPCONFIGPATH=/data/orgs/org0/admin/msp -w /data/peers \
    peer1-org0 /bin/bash -c 'peer channel join -b mychannel.block 2>&1 | tee /data/logs/peer1-org0.log'