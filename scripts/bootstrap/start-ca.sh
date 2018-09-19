#!/bin/bash

fabric-ca-server init -b $BOOTSTRAP_USER_PASS

cp $FABRIC_CA_SERVER_HOME/ca-cert.pem $TARGET_CERTFILE

aff=$aff"\n   org0: []"
aff="${aff#\\n   }"
sed -i "/affiliations:/a \\   $aff" \
   $FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml

fabric-ca-server start