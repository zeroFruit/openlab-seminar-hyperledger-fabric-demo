#!/bin/bash

source $(dirname "$0")/../env.sh
source $(dirname "$0")/../utils.sh

awaitSetup

# Enroll again to get the orderer's enrollment certificate (default profile)
fabric-ca-client enroll -d -u $ENROLLMENT_URL -M $ORDERER_GENERAL_LOCALMSPDIR

copyAdminCert $ORDERER_GENERAL_LOCALMSPDIR

env | grep ORDERER
orderer