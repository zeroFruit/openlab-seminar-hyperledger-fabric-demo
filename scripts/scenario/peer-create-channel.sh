#!/bin/bash

docker exec -it peer1-org0 /bin/bash -c '/scripts/bootstrap/create-channel.sh 2>&1 | tee /data/logs/peer1-org0.log'