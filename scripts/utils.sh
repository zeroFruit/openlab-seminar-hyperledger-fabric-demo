#!/bin/bash

# Switch to the current org's admin identity.  Enroll if not previously enrolled.
function switchToAdminIdentity {
   if [ ! -d $ORG_ADMIN_HOME ]; then
        dowait "$CA_NAME to start" 60 $CA_LOGFILE $CA_CERTFILE
        log "Enrolling admin '$ADMIN_NAME' with $CA_HOST ..."
        export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
        fabric-ca-client enroll -d -u http://$ADMIN_NAME:$ADMIN_PASS@$CA_HOST:7054

        mkdir -p $(dirname "${ORG_ADMIN_CERT}")
        cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_CERT
        mkdir $ORG_ADMIN_HOME/msp/admincerts
        cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_HOME/msp/admincerts
   fi
   export CORE_PEER_MSPCONFIGPATH=$ORG_ADMIN_HOME/msp
}

# Enroll the CA administrator
function enrollCAAdmin {
   waitPort "$CA_NAME to start" 90 $CA_LOGFILE $CA_HOST 7054
   log "Enrolling with $CA_NAME as bootstrap identity ..."
   export FABRIC_CA_CLIENT_HOME=/data/ca/$CA_NAME
   fabric-ca-client enroll -d -u http://$CA_ADMIN_USER_PASS@$CA_HOST:7054
}

# Copy the org's admin cert into some target MSP directory
# This is only required if ADMINCERTS is enabled.
function copyAdminCert {
    if [ $# -ne 1 ]; then
        fatal "Usage: copyAdminCert <targetMSPDIR>"
    fi

    dstDir=$1/admincerts
    mkdir -p $dstDir
    dowait "$ORG administator to enroll" 60 $SETUP_LOGFILE $ORG_ADMIN_CERT
    cp $ORG_ADMIN_CERT $dstDir
}


# Wait for one or more files to exist
# Usage: dowait <what> <timeoutInSecs> <errorLogFile> <file> [<file> ...]
function dowait {
   if [ $# -lt 4 ]; then
      fatal "Usage: dowait: $*"
   fi
   local what=$1
   local secs=$2
   local logFile=$3
   shift 3
   local logit=true
   local starttime=$(date +%s)
   for file in $*; do
      until [ -f $file ]; do
         if [ "$logit" = true ]; then
            log -n "Waiting for $what ..."
            logit=false
         fi
         sleep 1
         if [ "$(($(date +%s)-starttime))" -gt "$secs" ]; then
            echo ""
            fatal "Failed waiting for $what ($file not found); see $logFile"
         fi
         echo -n "."
      done
   done
   echo ""
}

# Wait for a process to begin to listen on a particular host and port
# Usage: waitPort <what> <timeoutInSecs> <errorLogFile> <host> <port>
function waitPort {
   set +e
   local what=$1
   local secs=$2
   local logFile=$3
   local host=$4
   local port=$5
   nc -z $host $port > /dev/null 2>&1
   if [ $? -ne 0 ]; then
      log -n "Waiting for $what ..."
      local starttime=$(date +%s)
      while true; do
         sleep 1
         nc -z $host $port > /dev/null 2>&1
         if [ $? -eq 0 ]; then
            break
         fi
         if [ "$(($(date +%s)-starttime))" -gt "$secs" ]; then
            fatal "Failed waiting for $what; see $logFile"
         fi
         echo -n "."
      done
      echo ""
   fi
   set -e
}

# log a message
function log {
   if [ "$1" = "-n" ]; then
      shift
      echo -n "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   else
      echo "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   fi
}

# fatal a message
function fatal {
   log "FATAL: $*"
   exit 1
}